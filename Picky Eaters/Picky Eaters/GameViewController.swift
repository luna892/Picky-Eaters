//
//  GameViewController.swift
//  Picky Eaters
//
//  Created by Luna Eason on 3/24/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
//        // including entities and graphs.
//        if let scene = GKScene(fileNamed: "GameScene") {
//
//            // Get the SKScene from the loaded GKScene
//            if let sceneNode = scene.rootNode as! GameScene? {
//
//                // Copy gameplay related content over to the scene
//                sceneNode.entities = scene.entities
//                sceneNode.graphs = scene.graphs
//
//                // Set the scale mode to scale to fit the window
//                sceneNode.scaleMode = .aspectFill
//
//                // Present the scene
//                if let view = self.view as! SKView? {
//                    view.presentScene(sceneNode)
//
//                    view.ignoresSiblingOrder = true
//
//                    view.showsFPS = true
//                    view.showsNodeCount = true
//                }
//            }
//        }
//    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      let scene = GameScene(size: view.bounds.size)
      let skView = view as! SKView
      skView.showsFPS = true
      skView.showsNodeCount = true
      skView.ignoresSiblingOrder = true
      scene.scaleMode = .resizeFill
      skView.presentScene(scene)

    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
