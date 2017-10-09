//
//  GameElements.swift
//  colorGame
//
//  Created by Gareth on 09.10.17.
//  Copyright © 2017 Gareth. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
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
        
        player?.physicsBody = SKPhysicsBody(circleOfRadius: player!.size.width / 2)
        
        if let body = player?.physicsBody {
            // simuation of air friction, would slow us down
            body.linearDamping = 0
            // set the cat bitmask
            body.categoryBitMask = playerCategory
            // turn off collisions that would influence other objects, as we dont want to move them
            body.collisionBitMask = 0
            // who do I want to know about contact with
            body.contactTestBitMask = targetCategory | enemyCategory
        }
        
        // add it to the node tree
        self.addChild(player!)
        
        if let pulse = SKEmitterNode(fileNamed: "pulse") {
            // add the pulse to the player
            player?.addChild(pulse)
            pulse.position = CGPoint(x: 0, y: 0)
        }
    }
    
    func createTarget() {
        if let target = self.childNode(withName: "target") as? SKSpriteNode {
            
            target.physicsBody = SKPhysicsBody(circleOfRadius: target.size.width / 2)
            
            if let body = target.physicsBody {
                body.categoryBitMask = targetCategory
                // dont get effected by collisions
                body.collisionBitMask = 0
            }
            
            self.target = target
        }
    }
    
    func createEnemy(type: Enemies, forTrack track: Int) -> SKShapeNode? {
        let enemySprite = SKShapeNode()
        
        switch type {
        case .small:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 70), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.4431, green: 0.5529, blue: 0.7451, alpha: 1)
        case .medium:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 100), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.4039, blue: 0.4039, alpha: 1)
        case .large:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 130), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.6392, blue: 0.4039, alpha: 1)
            
        }
        
        guard let enemyPosition = tracksArray?[track].position else { return nil }
        
        // depending on the direction we need to change y posiiton
        let up = directionArray[track]
        
        enemySprite.position.x = enemyPosition.x
        enemySprite.position.y = (up) ? -139 : self.size.height + 130
        
        enemySprite.physicsBody = SKPhysicsBody(edgeLoopFrom: enemySprite.path!)
        if let body =  enemySprite.physicsBody {
            body.velocity = (up) ? CGVector(dx: 0, dy: velocityArray[track]) : CGVector(dx: 0, dy: -velocityArray[track])
            
            body.categoryBitMask = enemyCategory
        }
        
        
        enemySprite.name = "Enemy"
        
        return enemySprite
    }
    
}

