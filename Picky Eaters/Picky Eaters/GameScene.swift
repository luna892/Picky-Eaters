//
//  GameScene.swift
//  Picky Eaters
//
//  Created by Luna Eason on 3/24/22.
//

import SpriteKit
import GameplayKit

// 23 objects out of 32 available so far
//struct PhysicsCategory {
//    static let none         : UInt32 = 0
//    static let all          : UInt32 = UInt32.max
//
//    //Dinosaurs
//    static let blueDinosaur : UInt32 = 0b1
//    static let redDinosaur  : UInt32 = 0b10
//    static let greenDinosaur: UInt32 = 0b100
//
//    //Foods
//    static let banana       : UInt32 = 0b1000
//    static let apple        : UInt32 = 0b10000
//    static let strawberry   : UInt32 = 0b100000
//    static let pizza        : UInt32 = 0b1000000
//    static let icecream     : UInt32 = 0b10000000
//    static let frenchfries  : UInt32 = 0b100000000
//    static let blueberry    : UInt32 = 0b1000000000
//    static let cheese       : UInt32 = 0b10000000000
//    static let eggs         : UInt32 = 0b100000000000
//    static let avocado      : UInt32 = 0b1000000000000
//    static let pineapple    : UInt32 = 0b10000000000000
//    static let cherry       : UInt32 = 0b100000000000000
//    static let pear         : UInt32 = 0b1000000000000000
//    static let potatoe      : UInt32 = 0b10000000000000000
//    static let onion        : UInt32 = 0b100000000000000000
//    static let carrot       : UInt32 = 0b1000000000000000000
//    static let broccoli     : UInt32 = 0b10000000000000000000
//}

struct PhysicsObject {
    var fileName : String
    var iconFileName: String = ""
    var physicsCategory: UInt32
}

let greenDinosaur   = PhysicsObject(fileName: "greenDinosaur"   , physicsCategory: 0b100)
let apple           = PhysicsObject(fileName: "apple"           , iconFileName: "appleIcon",    physicsCategory: 0b1000)
let banana          = PhysicsObject(fileName: "banana"          , iconFileName: "bananaIcon",   physicsCategory: 0b10000)
let pizza           = PhysicsObject(fileName: "pizza"           , iconFileName: "pizzaIcon",    physicsCategory: 0b1000000)

let allFoods = [apple, banana, pizza]

// TODO: Let player select which dinosaur they are from starting screen
var dinosaurPhysicsObject = greenDinosaur

// TODO: randomize what dinosaur wants to eat
func getDesiredMeal() -> Array<PhysicsObject> {
    if dinosaurPhysicsObject.fileName == "greenDinosaur" {
        return [apple, apple, apple, banana, banana, pizza]
    }
    return []
}

// TODO: manage what level user is on
var currentLevel = 1

var happinessMeter = 2

var currentMeal = getDesiredMeal()

let foodSpeed = CGFloat(3.0)

func random() -> CGFloat {
  return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
  return random() * (max - min) + min
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    let firstBody = contact.bodyA
    let secondBody = contact.bodyB
    // TODO: do something with dinosaur body
    var dinosaurBody : SKPhysicsBody
    var foodBody : SKPhysicsBody
        
    // Find which body is dinosaur and which is food
    // If a dinosaur is not found, then ignore collision
    if firstBody.categoryBitMask == dinosaurPhysicsObject.physicsCategory {
        dinosaurBody = firstBody
        foodBody = secondBody
    }
    else if secondBody.categoryBitMask == dinosaurPhysicsObject.physicsCategory {
        dinosaurBody = secondBody
        foodBody = firstBody
    } else {
        return
    }
        
    let foodPhysicsObject = allFoods.first(where: {$0.physicsCategory == foodBody.categoryBitMask})
    if (foodPhysicsObject == nil) {
        print("!! COLLIDE OCCURRED BUT COULD NOT FIND FOOD PHYSICS OBJECT FROM FOOD MASK !!")
        return
    }
    foodDidCollideWithDinosaur(food: (foodBody.node as? SKSpriteNode)!, foodPhysicsObject: foodPhysicsObject!)
    }
}

class GameScene: SKScene {
    let dinosaur = SKSpriteNode(imageNamed: dinosaurPhysicsObject.fileName)
        
    override func didMove(to view: SKView) {
        // TODO: Add background image
        backgroundColor = SKColor.white
        dinosaur.position = CGPoint(x: size.width * 0.1, y: size.height * 0.1 + dinosaur.size.height/2)
        dinosaur.name = dinosaurPhysicsObject.fileName
        
        dinosaur.physicsBody = SKPhysicsBody(rectangleOf: dinosaur.size)
        dinosaur.physicsBody?.isDynamic = true
        dinosaur.physicsBody?.categoryBitMask = dinosaurPhysicsObject.physicsCategory
        dinosaur.physicsBody?.contactTestBitMask = 0b1111111000
        dinosaur.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(dinosaur)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        drawMeals()
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addFood),
                SKAction.wait(forDuration: 1.0)
            ])
        ))
    }
    
    func drawMeals () {
        var currentMealPositionX = size.width
        
        for mealPhysicsObj in currentMeal {
            
            let meal = SKSpriteNode(imageNamed: mealPhysicsObj.iconFileName)
            
            meal.name = mealPhysicsObj.iconFileName
            
            //If it's the first food being created, give it extra space
            if (currentMealPositionX == size.width) {
                currentMealPositionX = currentMealPositionX - meal.size.width
            }
            
            let currentMealPositionY = size.height - meal.size.height
            
            meal.position = CGPoint(x: currentMealPositionX, y: currentMealPositionY)
            
            addChild(meal)
            
            currentMealPositionX = currentMealPositionX - meal.size.width - 5
        }
    }
    
    func removeMealsFromParent() {
        for meal in currentMeal {
            let mealToBeRemoved = childNode(withName: meal.iconFileName)
            mealToBeRemoved?.removeFromParent()
        }
    }
    
    func addFood() {
        let nextFood = getNextFood()
        
        let food = SKSpriteNode(imageNamed: nextFood.fileName)
        let positionX = size.width + food.size.width/2
        // offsetY places the food at a height higher above the ground
        // TODO: change this number to match the height of the ground
        let offsetY = size.height * 0.5
        let positionY = random(min: food.size.height/2 + offsetY, max: size.height - food.size.height / 2)
        food.position = CGPoint(x: positionX, y: positionY)
        addChild(food)
        
        food.physicsBody = SKPhysicsBody(rectangleOf: food.size)
        food.physicsBody?.isDynamic = true
        food.physicsBody?.categoryBitMask = nextFood.physicsCategory
        food.physicsBody?.contactTestBitMask = dinosaurPhysicsObject.physicsCategory
        food.physicsBody?.usesPreciseCollisionDetection = true
        
        let actionMove = SKAction.move(to: CGPoint(x: -food.size.width/2, y: positionY),
                                       duration: TimeInterval(foodSpeed))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        // TODO: Add end game sequence here
        food.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func getNextFood() -> PhysicsObject {
        var randomInt = 0
        var nextFruit = apple
        
        if currentLevel == 1 {
            randomInt = Int.random(in:1..<5)
            print(randomInt)
            if randomInt < 2 {
                nextFruit = apple
            } else if randomInt > 1 && randomInt < 4  {
                nextFruit = banana
            } else {
                nextFruit = pizza
            }
        }
        return nextFruit
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dinosaur jumps
        let jumpUpAction = SKAction.moveBy(x: 0, y: 60, duration: 0.2)
        let jumpDownAction = SKAction.moveBy(x: 0, y: -60, duration: 0.2)
        let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction])
        dinosaur.run(jumpSequence)
    }
    
    func foodDidCollideWithDinosaur(food: SKSpriteNode, foodPhysicsObject: PhysicsObject) {
        print ("Hit")
        // TODO: Add collision detecting only at mouth
        food.removeFromParent()
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        
        let index = currentMeal.firstIndex(where: {$0.physicsCategory == foodPhysicsObject.physicsCategory})
        
        // Remove all meal nodes
        // Update the current meals left
        // Redraw the current meals
        if index != nil {
            removeMealsFromParent()
            
            currentMeal.remove(at: index!)

            if currentMeal.isEmpty {
                let gameOverScene = GameOverScene(size: self.size, won: true)
                view?.presentScene(gameOverScene, transition: reveal)
            }
            
            drawMeals()
        } else {
            happinessMeter = happinessMeter - 1
        }

        if happinessMeter == 0 {
            let gameOverScene = GameOverScene(size: self.size, won: false)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
}
