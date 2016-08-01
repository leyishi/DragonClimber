//
//  GameScene.swift
//  Dragon Climber
//
//  Created by Alice Shi on 7/13/16.
//  Copyright (c) 2016 Alice Shi. All rights reserved.
//

import SpriteKit
import AVKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    enum GameState {                                  /* different game states */
        case Title, Paused, Playing, Gameover
    }
    
    var scrollSpeed: CGFloat = 100                 /* Scroll Speed */
    let fixedDelta: CFTimeInterval = 1.0/60.0       /* 60 FPS */
    var scrollLayer: SKNode!                        /* UI Connections */
    var stoneLayer: SKNode!
    var rockArray: [Rock] = []                      /* Rock Array */
    var yPosition = 0                               /* Y position counter */
    
    var player: SKSpriteNode! = nil        /* player object that moves to the target */
    var rope: SKShapeNode!                 /* rope between player and target */
    var target: SKSpriteNode!              /* target that player moves to */
    var gameState: GameState = .Playing    /* game state management */
    var scoreLabel: SKLabelNode!           /* score label */
    var points = 0                         /* points counter */
    var rockCount = 0                      /* count for number of rocks in avalanche */
    var LeftEPoint: SKSpriteNode!          /* Left exclamation point */
    var RightEPoint: SKSpriteNode!         /* Right exclamation point */
    var pauseButton: MSButtonNode!         /* pause button to bring menu down */
    var dropDownMenu: SKSpriteNode!        /* Menu that drops down after pause button is hit */
    var restartButtonInGame: MSButtonNode!  /* Restart Button that restarts the gamea fter the pause button is hit;menu */
    
    override func didMoveToView(view: SKView) {
        /* Setup scene here */
        
        /* Reference to UI Connections */
        scrollLayer = self.childNodeWithName("scrollLayer")
        stoneLayer = self.childNodeWithName("stoneLayer")
        scoreLabel = self.childNodeWithName("scoreLabel") as! SKLabelNode
        LeftEPoint = self.childNodeWithName("LeftEPoint") as! SKSpriteNode
        RightEPoint = self.childNodeWithName("RightEPoint") as! SKSpriteNode
        pauseButton = self.childNodeWithName("pauseButton") as! MSButtonNode
        dropDownMenu = self.childNodeWithName("dropDownMenu") as! SKSpriteNode
        restartButtonInGame = self.childNodeWithName("restartButtonInGame") as! MSButtonNode
        
        /* Set physics world delegate */
        physicsWorld.contactDelegate = self
        
        /* makes first rock appear */
        let rock = Rock()
        rockArray.append(rock)
        stoneLayer.addChild(rock)
        
        /* adds number of random rocks */
        addRandomRocks(15)
        
        /* Player */
        player = Player()
        scrollLayer.addChild(player)
        
        /* Rope */
        rope = SKShapeNode()
        rope.fillTexture = SKTexture(imageNamed: "ropeTexture")
        rope.lineWidth = 3
        rope.zPosition = 4
        scrollLayer.addChild(rope)
        
        /* Target */
        target = SKSpriteNode(imageNamed: "Shuriken.png")
        let rotateShuriken = SKAction.rotateByAngle(5, duration: 0.1)
        target.runAction(SKAction.repeatActionForever(rotateShuriken), withKey: "stopRotatingShuriken")
        target.position.x = player.position.x
        target.position.y = player.position.y
        target.zPosition = 5
        scrollLayer.addChild(target)
        target.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        target.physicsBody?.dynamic = false
        target.setScale(1.5)
        
        /* Background Music */
        let gameSFX = SKAction.playSoundFileNamed("gameMusic.mp3", waitForCompletion: false)
        self.runAction(gameSFX)
        
        /* Resets score label everytime game restarts */
        scoreLabel.text = String(points)
        
        /* sets exclamation point to hidden normally */
        LeftEPoint.hidden = true
        RightEPoint.hidden = true
        
        // Spawns Avalanche
        spawnRandomAvalanche()
        
        //Calls Clouds func to make clouds appear on screen
        Clouds()
        
        /* sets drop down menu to be hidden normally */
        dropDownMenu.hidden = true
        restartButtonInGame.hidden = true
        
        //paus
        pauseButton.selectedHandler = pauseGame
    }
    
    func spawnRandomAvalanche() {
        
        let randomTimeAvalanche = Double(arc4random_uniform(10)+15)
        let randomGen = arc4random_uniform(UInt32(2))
        let waitAvalanche = SKAction.waitForDuration(3.0)
        let runAvalancheLeft = SKAction.runBlock({
            self.avalancheLeft()
            self.spawnRandomAvalanche()
        })
        let runAvalancheRight = SKAction.runBlock({
            self.avalancheRight()
            self.spawnRandomAvalanche()
        })
        
        let waitexclamationPoint = SKAction.waitForDuration(randomTimeAvalanche - 3.0)
        let runexclamationPointLeft = SKAction.runBlock({
            self.flashingExPointLeft()
        })
        let runexclamationPointRight = SKAction.runBlock({
            self.flashingExPointRight()
        })
        
        if randomGen == 0 {
            print(randomGen)
            self.runAction(SKAction.sequence([waitexclamationPoint,runexclamationPointLeft,waitAvalanche,runAvalancheLeft]))
        } else {
            print(randomGen)
                self.runAction(SKAction.sequence([waitexclamationPoint,runexclamationPointRight,waitAvalanche,runAvalancheRight]))
        }
        
    }
    
    func spawn randomDragon() {
    
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if gameState == .Gameover {
            return
        }
        
        /* Called when a touch begins */
        
        // Get the location of the touch
        let touch = touches.first!
        let location = touch.locationInNode(scrollLayer)
        let getNode = stoneLayer.nodeAtPoint(location)
        
        // Set up some actions that will move the target to the touch location
        // rotates shuriken
        let rotateShuriken = SKAction.rotateByAngle(5, duration: 0.1)
        target.runAction(SKAction.repeatActionForever(rotateShuriken), withKey: "stopRotatingShuriken")
        let launchHook = SKAction.moveTo(location, duration: 0.25)
        target.runAction(launchHook)
        
        // Setup an action that will move the player to the location of the touch
        // This time adds a wait so the player follows a moment later
        
        if getNode is Rock {
            let wait = SKAction.waitForDuration(0.25)
            let movePlayer = SKAction.moveTo(location, duration: 0.25)
            let playerAction = SKAction.sequence([wait, movePlayer])
            target.removeActionForKey("stopRotatingShuriken")
            player.runAction(playerAction)
        } else {
            let hookWait = SKAction.waitForDuration(0.25)
            let moveHook = SKAction.moveTo(player.position, duration: 0.50)
            let reverseLaunchHook = SKAction.sequence([hookWait, moveHook])
            target.runAction(reverseLaunchHook)
        }
        
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // if it is gameover, does not continue the game
        if gameState == .Gameover {
            return
        }
        
        /* if the player goes off the screen, it becomes gameover */
        let position = scrollLayer.convertPoint(player.position, toNode: self)
        if position.y < 0 {
            gameState = .Gameover
        }
        
        /* Process World Scrolling */
        scrollWorld()
        
        /* Process stone layer scrolling */
        scrollStone()
        
        /* Process re-positioning of rocks */
        updateRocks()
        
        /* Speeds up scrolling of the world */
        scrollSpeed += 0.01
        
        if player.position != target.position {
            // This code draws a line between the player and target
            let ropePath = CGPathCreateMutable()
            CGPathMoveToPoint(ropePath, nil, player.position.x, player.position.y)
            CGPathAddLineToPoint(ropePath, nil, target.position.x, target.position.y)
            rope.path = ropePath
        
        }
        
        /* Increment score */
        points += 1
        
        /* update score label */
        scoreLabel.text = String(points)
        
    }
    
    func scrollStone() {
        /* scrolls the stone layer */
        stoneLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
    }
    
    func scrollWorld() {
        /* scrolls the world */
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for child in scrollLayer.children {
            
            if child.name == "Wall" {
                
                /* Get ground node position, convert node position to scene space */
                let wallPosition = scrollLayer.convertPoint(child.position, toNode: self)
                
                /* Check if ground sprite has left the scene */
                if wallPosition.y <= (-self.frame.size.height/2) {
                    
                    /* Reposition ground sprite to the second starting position */
                    let newPosition = CGPointMake(wallPosition.x, self.size.height/2 + child.frame.size.height)
                    
                    /* Convert new node position back to scroll layer space */
                    child.position = self.convertPoint(newPosition, toNode: self.scrollLayer)
                }
            }
        }
    }
    
    func Clouds() {
        /* adds clouds with random y positions */
        
        /* Load Cloud1 particle effect */
        let cloud1Particle = SKEmitterNode(fileNamed: "Cloud1.sks")!
        cloud1Particle.advanceSimulationTime(5)
        cloud1Particle.targetNode = scrollLayer
        self.addChild(cloud1Particle)

        /* Load Cloud2 particle effect */
        let cloud2Particle = SKEmitterNode(fileNamed: "Cloud2.sks")!
        cloud2Particle.advanceSimulationTime(5)
        cloud2Particle.targetNode = scrollLayer
        self.addChild(cloud2Particle)
        
        /* Load Cloud3 particle effect */
        let cloud3Particle = SKEmitterNode(fileNamed: "Cloud3.sks")!
        cloud3Particle.advanceSimulationTime(5)
        cloud3Particle.targetNode = scrollLayer
        self.addChild(cloud3Particle)
    }
    
    
    func addRandomRocks(nTimes: Int) {
        /* adds rocks with random x positions and increasing by 65 in the y position */
        var newY = 0
        for _ in 0..<nTimes {
            newY += Int(arc4random_uniform(UInt32(65) + 50))
            let newRock = Rock()
            let x = Int(arc4random_uniform(UInt32(150) + 40))
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
                newY += Int(arc4random_uniform(UInt32(65) + 50))
                yPosition = newY
                let x = Int(arc4random_uniform(UInt32(150) + 40))
                rock.position = CGPoint(x: x, y: newY)
            }
        }
    }
    
    func gameOver() {
        // Game Over state
        gameState = .Gameover
        
        // Makes the player fall off the screen
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
         //Makes the player die if he is contacted by the avalanche
        let contactA: SKPhysicsBody = contact.bodyA
        let contactB: SKPhysicsBody = contact.bodyB
        
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        /* If avalanche rock makes contact with player, gamestate will change to gameover */
        if nodeA.name == "testRock" && nodeB.name == "player" || nodeA.name == "player" && nodeB.name == "testRock" {
            gameOver()
            print("gameover")
        }
    }
    
    func avalancheLeft() {
        //creates an avalanche on the left side of the screen
        for i in 0...100 {
            let waitforRock = SKAction.waitForDuration(0.02*Double(i))
            let runBlock = SKAction.runBlock({
                let testRock = SKSpriteNode(imageNamed: "avalancheRock")
                testRock.name = "testRock"
                testRock.setScale(1.5)
                testRock.zPosition = 5
                let randomXPosLeft = Int(arc4random_uniform(UInt32(70))+90)
                testRock.position = CGPoint(x: randomXPosLeft, y: Int(self.frame.size.height))
                testRock.physicsBody = SKPhysicsBody(circleOfRadius: 10)
                testRock.physicsBody?.dynamic
                testRock.physicsBody?.contactTestBitMask = 15
                testRock.physicsBody?.affectedByGravity = true
                self.addChild(testRock)
                self.rockCount += 1
            })
            self.runAction(SKAction.sequence([waitforRock,runBlock]))
            rockCount = 0
            
        }

    }
    
    func avalancheRight() {
        //creates an avalanche on the right side of the screen
        for i in 0...100 {
            let waitforRock = SKAction.waitForDuration(0.02*Double(i))
            let runBlock = SKAction.runBlock({
                let testRock = SKSpriteNode(imageNamed: "avalancheRock")
                testRock.name = "testRock"
                testRock.setScale(1.5)
                testRock.zPosition = 5
                let randomXPosRight = Int(arc4random_uniform(UInt32(90))+200)
                testRock.position = CGPoint(x: randomXPosRight, y: Int(self.frame.size.height))
                testRock.physicsBody = SKPhysicsBody(circleOfRadius: 10)
                testRock.physicsBody?.dynamic
                testRock.physicsBody?.affectedByGravity = true
                self.addChild(testRock)
                self.rockCount += 1
            })
            self.runAction(SKAction.sequence([waitforRock,runBlock]))
            rockCount = 0
        }

    }
    
    func flashingExPointLeft() {
        // creates an exclamation point on the left side of the screen
        let waitTime = 3.0
        let ExWait = SKAction.waitForDuration(waitTime)
        let runLeft = SKAction.runBlock({
            self.LeftEPoint.hidden = false
        })
        let stopLeft = SKAction.runBlock({
            self.LeftEPoint.hidden = true
        })
        self.runAction(SKAction.sequence([runLeft,ExWait,stopLeft]))
        
    }
    
    func flashingExPointRight() {
        //creates an exclamation point on the right side of the screen
        let waitTime = 3.0
        let ExWait = SKAction.waitForDuration(waitTime)
        let runRight = SKAction.runBlock({
            self.RightEPoint.hidden = false
        })
        let stopRight = SKAction.runBlock({
            self.RightEPoint.hidden = true
        })
        self.runAction(SKAction.sequence([runRight,ExWait,stopRight]))
        
       
    }
    
    func pauseGame() {
        // pauses the game for the drop down menu to appear
        
        /* set up pause button handler */
        pauseButton.selectedHandler = {
            self.dropDownMenu.hidden = false
            self.restartButtonInGame.hidden = false
            self.paused = true
        }
    }
    
    func restartGame() {
        // restarts the game from the drop down menu
        
        /* set up restart button handler */
        restartButtonInGame.selectedHandler = {
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFill
            
            /* Show debug */
            skView.showsPhysics = true
            skView.showsDrawCount = true
            skView.showsFPS = false
            
            /* Restart game scene */
            skView.presentScene(scene)
        }
    }
    
    
    func dragonLeft() {
        var shape = SKShapeNode()
        shape.strokeColor = UIColor.clearColor()
        shape.position = CGPoint(x: 125, y:0)
        addChild(shape)
        shape.zPosition = 15
        
        var path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 50), controlPoint: CGPoint(x: 50,y: 30))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 100), controlPoint: CGPoint(x: -50,y: 80))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 150), controlPoint: CGPoint(x: 50,y: 120))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 200), controlPoint: CGPoint(x: -50,y: 170))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 250), controlPoint: CGPoint(x: 50,y: 220))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 300), controlPoint: CGPoint(x: -50,y: 280))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 350), controlPoint: CGPoint(x: 50,y: 320))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 400), controlPoint: CGPoint(x: -50,y: 380))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 450), controlPoint: CGPoint(x: 50,y: 420))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 500), controlPoint: CGPoint(x: -50,y: 480))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 550), controlPoint: CGPoint(x: 50,y: 520))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 600), controlPoint: CGPoint(x: -50,y: 580))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 650), controlPoint: CGPoint(x: 50,y: 620))
        path.addQuadCurveToPoint(CGPoint(x: 0,y: 700), controlPoint: CGPoint(x: -50,y: 680))
        shape.path = path.CGPath
        
        
        
        var shape2 = SKShapeNode(circleOfRadius: 10)
        shape2.zPosition = 16
        shape2.strokeColor = UIColor.blueColor()
        shape2.fillColor = UIColor.blueColor()
        shape2.position = CGPoint(x: 125, y:0)
        shape2.lineWidth = 3
        addChild(shape2)
        shape2.runAction(SKAction.followPath(shape.path!, speed: 300))
        
    }

    
}