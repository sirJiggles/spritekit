//
//  GameScene.swift
//  colorGame
//
//  Created by Gareth on 08.10.17.
//  Copyright © 2017 Gareth. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Enemies: Int {
    case small
    case medium
    case large
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var tracksArray: [SKSpriteNode]? = [SKSpriteNode]()
    var player: SKSpriteNode?
    var target: SKSpriteNode?
    
    var currentTrack = 0
    var movingToTrack = false
    
    // init this first so it is laoded early
    var moveSound = SKAction.playSoundFileNamed("Sounds/move.wav", waitForCompletion: false)
    
    // various speeds
    let trackVelocities = [180, 200, 250]
    var directionArray = [Bool]()
    // int for every track
    var velocityArray = [Int]()
    
    // category bitmasks for colllisions
    let playerCategory: UInt32 = 0x1 << 1
    let enemyCategory: UInt32 = 0x1 << 2
    let targetCategory: UInt32 = 0x1 << 3
    
    // MARK: lifecycle
    // like view did load in UIKit
    override func didMove(to view: SKView) {
        setUpTracks()
        createPlayer()
        createTarget()
        
        self.physicsWorld.contactDelegate = self
        
        // add values to direction and velocty
        if let numberOfTracks = tracksArray?.count {
            for _ in 0 ... numberOfTracks {
                // values from 0 - 2
                let randomNumForVelocity = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
                velocityArray.append(trackVelocities[randomNumForVelocity])
                directionArray.append(GKRandomSource.sharedRandom().nextBool())
            }
        }
        
        // call span enemies every two seconds
        self.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run({
                self.spawnEnemies()
            }),
            SKAction.wait(forDuration: 2)
        ])))
    }
    
    // MARK: Touch control
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // location of the touch in root node
            let location = touch.location(in: self)
            let node = self.nodes(at: location).first
            
            // check the name of what we touched
            if node?.name == "right" {
                moveToNextTrack()
            } else if node?.name == "up" {
                moveVertically(up: true)
            } else if node?.name == "down" {
                moveVertically(up: false)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movingToTrack {
            player?.removeAllActions()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movingToTrack {
            player?.removeAllActions()
        }
    }
    
    // MARK: Physics collisions
    func didBegin(_ contact: SKPhysicsContact) {
        var playerBody: SKPhysicsBody
        var otherBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            // as player is smallest cat bitmask, we know this is a player
            playerBody = contact.bodyB
            otherBody = contact.bodyB
        } else {
            playerBody = contact.bodyB
            otherBody = contact.bodyA
        }
        
        if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == enemyCategory {
            print("enemy hit")
        } else if (playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == targetCategory) {
            print("target hit")
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    

}
