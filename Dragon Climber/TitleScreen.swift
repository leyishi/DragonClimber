//
//  TitleScreen.swift
//  Dragon Climber
//
//  Created by Alice Shi on 7/27/16.
//  Copyright © 2016 Alice Shi. All rights reserved.
//


import SpriteKit

class Titlescreen: SKScene {
    /* UI Connections */
    var playButton: MSButtonNode!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        /* Set UI connections */
        playButton = self.childNodeWithName("playButton") as! MSButtonNode
        
        /* Setup restart button selection handler */
        playButton.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFill
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsDrawCount = true
            
            /* Start game scene */
            skView.presentScene(scene)
        }
        
    }
}