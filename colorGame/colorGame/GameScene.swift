//
//  GameScene.swift
//  colorGame
//
//  Created by Gareth on 08.10.17.
//  Copyright © 2017 Gareth. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Enemies: {
    case small
    case medium
    case large
}

class GameScene: SKScene {
    var tracksArray: [SKSpriteNode]? = [SKSpriteNode]()
    var player: SKSpriteNode?
    
    var currentTrack = 0
    var movingToTrack = false
    
    // init this first so it is laoded early
    var moveSound = SKAction.playSoundFileNamed("Sounds/move.wav", waitForCompletion: false)
    
    // MARK: lifecycle
    // like view did load in UIKit
    override func didMove(to view: SKView) {
        setUpTracks()
        createPlayer()
        tracksArray?.first?.color = UIColor.green
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
        
        // add it to the node tree
        self.addChild(player!)
        
        if let pulse = SKEmitterNode(fileNamed: "pulse") {
            // add the pulse to the player
            player?.addChild(pulse)
            pulse.position = CGPoint(x: 0, y: 0)
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
        
        enemySprite.position.x = enemyPosition.x
        // off the screen for now
        enemySprite.position.y = 50
        
        return enemySprite
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
