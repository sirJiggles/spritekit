//
//  GameScene.swift
//  colorGame
//
//  Created by Gareth on 08.10.17.
//  Copyright © 2017 Gareth. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var tracksArray: [SKSpriteNode]? = [SKSpriteNode]()
    var player: SKSpriteNode?
    
    func setUpTracks() {
        for i in 0 ... 8 {
            if let track = self.childNode(withName: "\(i)") as? SKSpriteNode {
                tracksArray?.append(track)
            }
        }
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        guard let playerPosition = tracksArray?.first?.position.x else { return }
        // in the middle of the game scene height
        player?.position = CGPoint(x: playerPosition, y: self.size.height / 2)
        
        // add it to the node tree
        self.addChild(player!)
    }
    
    // like view did load in UIKit
    override func didMove(to view: SKView) {
        setUpTracks()
        createPlayer()
        tracksArray?.first?.color = UIColor.green
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
