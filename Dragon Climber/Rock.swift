//
//  Rock.swift
//  Dragon Climber
//
//  Created by Alice Shi on 7/18/16.
//  Copyright © 2016 Alice Shi. All rights reserved.
//

import Foundation
import SpriteKit

class Rock: SKSpriteNode, SKPhysicsContactDelegate{
    
    init() {
        let texture = SKTexture(imageNamed: "Bamboo")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        self.zPosition = 3

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}