//
//  GameScene.swift
//  Dragon Climber
//
//  Created by Alice Shi on 7/13/16.
//  Copyright (c) 2016 Alice Shi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    /* Scroll Speed */
    let scrollSpeed: CGFloat = 160
    
    /* Fixed Delta */
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    
    
    /* UI Connections */
    var Rock: SKSpriteNode!
    var scrollLayer: SKNode!

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        /* Reference to UI Connections */
        Rock = self.childNodeWithName("Rock") as! SKSpriteNode
        scrollLayer = self.childNodeWithName("scrollLayer")
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        /* Process World Scrolling */
        scrollWorld()
    }
    
    func scrollWorld() {
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
    }
    
    func createRocks() {
        /* creates randomized rocks */
        
        let randomRockpos = arc4random()
}
