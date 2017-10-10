//
//  GameFunctions.swift
//  colorGame
//
//  Created by Gareth on 09.10.17.
//  Copyright © 2017 Gareth. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    func launchGameTimer() {
        let timeAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.run({
                self.remainingTime -= 1
            }),
            SKAction.wait(forDuration: 1)
        ]))
        timeLabel?.run(timeAction)
    }
    
    func spawnEnemies() {
        var randomTrackNum = 0
        let createPowerUp = GKRandomSource.sharedRandom().nextBool()
        
        if createPowerUp {
            // as we have 7 tracks
            randomTrackNum = GKRandomSource.sharedRandom().nextInt(upperBound: 6) + 1
            
            if let powerUpObj = self.createPowerUp(forTrack: randomTrackNum) {
                self.addChild(powerUpObj)
            }
        }
        
        for i in 1 ... 7 {
            // only make a enemy if not putting power up on this track
            if randomTrackNum != i {
                let randomType = Enemies(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: 3))!
                if let newEnemy = createEnemy(type: randomType, forTrack: i) {
                    self.addChild(newEnemy)
                }
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
    
    func moveVertically(up: Bool) {
        let amount = (up) ? 3 : -3 as CGFloat
        let moveAction = SKAction.moveBy(x: 0, y: amount, duration: 0.01)
        let repeatAction = SKAction.repeatForever(moveAction)
        player?.run(repeatAction)
    }
    
    func moveToNextTrack() {
        player?.removeAllActions()
        
        movingToTrack = true
        
        let nextTrackIndex = currentTrack + 1
        
        if !(tracksArray?.indices.contains(nextTrackIndex))! {
            return
        }
        
        // calculate the next pos
        guard let nextTrack = tracksArray?[nextTrackIndex].position else {
            return
        }
    
        
        if let player = self.player {
            let moveAction = SKAction.moveTo(x: nextTrack.x, duration: 0.02)
            
            let up = directionArray[nextTrackIndex]
            let velocityY = velocityArray[nextTrackIndex]
            
            player.run(moveAction, completion: {
                self.movingToTrack = false
                // if not on the last track
                if self.currentTrack != 8 {
                    // start moving the player in the same dir as the enemy on the track
                    self.player?.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityY) : CGVector(dx: 0, dy: -velocityY)
                } else {
                    self.player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
            })
            currentTrack += 1
            
            self.run(moveSound)
        }
    }
    
    // if hit enemy or come of the screen
    func movePlayerToStart() {
        if let player = self.player {
            // remove it from parent
            player.removeFromParent()
            // get rid of it
            self.player = nil
            self.createPlayer()
            // reset the track
            self.currentTrack = 0
        }
    }
    
    func nextLevel(playerPhysBod: SKPhysicsBody) {
        if let emmitter = SKEmitterNode(fileNamed: "fireworks") {
            self.currentScore += 1
            self.run(SKAction.playSoundFileNamed("Sounds/levelUp.wav", waitForCompletion: true))
            playerPhysBod.node?.addChild(emmitter)
            // wait then remove the emmiter
            self.run(SKAction.wait(forDuration: 0.5)) {
                emmitter.removeFromParent()
                self.movePlayerToStart()
            }
        }
    }
}
