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
    
    // MARK: Adding items to the scene functions
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
    
    func spawnEnemies() {
        for i in 1 ... 7 {
            let randomType = Enemies(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: 3))!
            if let newEnemy = createEnemy(type: randomType, forTrack: i) {
                self.addChild(newEnemy)
            }
        }
        // look through all the node tree for children with this name
        self.enumerateChildNodes(withName: "Enemy") { (node: SKNode, nil) in
            
            // if off the screeb remove
            if node.position.y < -150 || node.position.y > self.size.height + 150 {
                node.removeFromParent()
            }
        }
    }
    
    // MARK: moving function
    func moveVertically(up: Bool) {
        let amount = (up) ? 3 : -3 as CGFloat
        let moveAction = SKAction.moveBy(x: 0, y: amount, duration: 0.01)
        let repeatAction = SKAction.repeatForever(moveAction)
        player?.run(repeatAction)
    }
    
    func moveToNextTrack() {
        player?.removeAllActions()
        
        movingToTrack = true
        
        // calculate the next pos
        guard let nextTrack = tracksArray?[currentTrack + 1].position else {
            return
        }
        
        if let player = self.player {
            let moveAction = SKAction.moveTo(x: nextTrack.x, duration: 0.02)
            player.run(moveAction, completion: {
                self.movingToTrack = false
            })
            currentTrack += 1
            
            self.run(moveSound)
        }
    }
}
