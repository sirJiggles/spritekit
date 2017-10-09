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
