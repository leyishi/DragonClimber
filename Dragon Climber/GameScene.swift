//
//  GameScene.swift
//  Dragon Climber
//
//  Created by Alice Shi on 7/13/16.
//  Copyright (c) 2016 Alice Shi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let scrollSpeed: CGFloat = 160                  /* Scroll Speed */
    let fixedDelta: CFTimeInterval = 1.0/60.0       /* 60 FPS */
    var scrollLayer: SKNode!                        /* UI Connections */
    var stoneLayer: SKNode!
    var rockArray: [Rock] = []                      /* Rock Array */
    var rock = Rock()
    var yPosition = 0                               /* Y position counter */
    
    var player: SKSpriteNode! = nil        /* player object that moves to the target */
    var rope: SKShapeNode!                 /* rope between player and target */
    var target: SKSpriteNode!              /* target that player moves to */
   
    override func didMoveToView(view: SKView) {
        /* Setup scene here */
        
        /* Reference to UI Connections */
        scrollLayer = self.childNodeWithName("scrollLayer")
        stoneLayer = self.childNodeWithName("stoneLayer")
        
        /* makes first rock appear */
        var rock = Rock()
        rockArray.append(rock)
        stoneLayer.addChild(rock)
        
        /* adds number of random rocks */
        addRandomRocks(15)
        
        /* Player */
        player = Player()
        scrollLayer.addChild(player)
        
        /* Rope */
        rope = SKShapeNode()
        rope.zPosition = 4
        scrollLayer.addChild(rope)
        
        /* Target */
        let ropeTargetSize = CGSize(width: 10, height: 10)
        target = SKSpriteNode(color: UIColor.blueColor(), size: ropeTargetSize)
        target.position.x = player.position.x
        target.position.y = player.position.y
        target.zPosition = 4
        scrollLayer.addChild(target)
        target.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        target.physicsBody?.dynamic = false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */

        // Get the location of the touch
        let touch = touches.first!
        let location = touch.locationInNode(scrollLayer)
        
        // Set up some actions that will move the target to the touch location
        let launchHook = SKAction.moveTo(location, duration: 0.25)
        target.runAction(launchHook)
        
        // Setup an action that will move the player to the location of the touch
        // This time add a wait so the player follows a moment later.
        let wait = SKAction.waitForDuration(0.25)
        let movePlayer = SKAction.moveTo(location, duration: 0.25)
        let playerAction = SKAction.sequence([wait, movePlayer])
        player.runAction(playerAction)

        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

        
        /* Process World Scrolling */
        scrollWorld()
        
        /* Process stone layer scrolling */
        scrollStone()
        
        /* Process re-positioning of rocks */
        updateRocks()
        
        // This code draws a line between the player and target
        let ropePath = CGPathCreateMutable()
        CGPathMoveToPoint(ropePath, nil, player.position.x, player.position.y)
        CGPathAddLineToPoint(ropePath, nil, target.position.x, target.position.y)
        rope.path = ropePath
        rope.strokeColor = UIColor.orangeColor()
        rope.lineWidth = 4

        
        
    }
    
    func scrollStone() {
        /* scrolls the stone layer */
        stoneLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
    }

    func scrollWorld() {
        /* scrolls the world */
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
    }
    
    
    func addRandomRocks(nTimes: Int) {
         /* adds rocks with random x positions and increasing by 65 in the y position */
        var newY = 0
        for _ in 0..<nTimes {
            newY += Int(arc4random_uniform(UInt32(75) + 50))
            let newRock = Rock()
            let x = Int(arc4random_uniform(UInt32(200)))
            newRock.position = CGPoint(x: x, y: newY)
            self.rockArray.append(newRock)
            stoneLayer.addChild(newRock)
            yPosition = newY
        }
    }
    
    func updateRocks() {
        /* Once a rock is offscreen, takes its position and changes it to recycle rocks. Creates infinite number of rocks */
            for rock in stoneLayer.children as! [SKSpriteNode] {
                let rockPosition = stoneLayer.convertPoint(rock.position, toNode: self)
                if rockPosition.y <= 0 {
                    var newY = yPosition
                    newY += Int(arc4random_uniform(UInt32(75) + 50))
                    yPosition = newY
                    let x = Int(arc4random_uniform(UInt32(200)))
                    rock.position = CGPoint(x: x, y: newY)
                }
        }
    }
    
    

    
    
    
}