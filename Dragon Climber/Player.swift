//
//  Player.swift
//  Dragon Climber
//
//  Created by Alice Shi on 7/19/16.
//  Copyright © 2016 Alice Shi. All rights reserved.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode {
    
    init() {
        let texture = SKTexture(imageNamed: "FNB.png")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        self.name = "player"
        self.zPosition = 6
        self.position.x = 200
        self.position.y = 300
        self.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = 1
        self.physicsBody?.dynamic = false
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
