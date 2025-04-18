//
//  GameScene.swift
//  breakout game ios
//
//  Created by Samuel Amante on 4/1/25.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball = SKShapeNode()
    var ball2 = SKShapeNode()
    var paddle = SKSpriteNode()
    var bricks = [SKSpriteNode]()
    var loseZone = SKSpriteNode()
    var playLabel = SKLabelNode()
    var livesLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var playingGame = false
    var score = 0
    var lives = 3
    var removedBricks = 0
    
    override func didMove(to view: SKView) {
        createBackground()
        makeLoseZone()
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        makeLabels()
    }
    func createBackground() {
        let stars = SKTexture(imageNamed: "Stars")
        for i in 0...1 {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy (x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    func makeBall(_ targetBall: SKShapeNode) {
        targetBall.removeFromParent()
        targetBall.path = CGPath(ellipseIn: CGRect(x: -10, y: -10, width: 20, height: 20), transform: nil)
                                 targetBall.strokeColor = .black
                                 targetBall.fillColor = .yellow
        targetBall.name = "ball"
        
        targetBall.position = CGPoint(x: frame.midX, y: frame.midY)
        targetBall.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        targetBall.physicsBody?.isDynamic = true
        targetBall.physicsBody?.usesPreciseCollisionDetection = true
        targetBall.physicsBody?.friction = 0
        targetBall.physicsBody?.affectedByGravity = false
        targetBall.physicsBody?.restitution = 1
        targetBall.physicsBody?.linearDamping = 0
        targetBall.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        
        addChild(targetBall)
    }
    func resetGame() {
        makeBall(ball)
        makeBall(ball2)
        makePaddle()
        makeBricks()
        updateLabels()
    }
    func kickBall() {
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -5...5), dy: 5))
            
        ball2.physicsBody?.isDynamic = true
        ball2.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -5...5), dy: 5))
    }
    func updateLabels() {
        scoreLabel.text = "Score: \(score)"
        livesLabel.text = "Lives: \(lives)"
    }
    func makePaddle() {
        paddle.removeFromParent()
        paddle = SKSpriteNode(color: .white, size: CGSize(width: frame.width/4, height: 20))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        addChild(paddle)
    }
    func makeBrick(x: Int, y: Int, color: UIColor) {
        let brick = SKSpriteNode(color: color, size: CGSize(width: 50, height: 20))
        brick.position = CGPoint(x: x, y: y)
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        addChild(brick)
        bricks.append(brick)
    }
    func makeLoseZone() {
        loseZone = SKSpriteNode(color: .red, size: CGSize(width: frame.width, height: 50))
        loseZone.position = CGPoint(x: frame.midX, y: frame.midY + 25)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        addChild(loseZone)
    }
    func makeLabels() {
        playLabel.fontSize = 24
        playLabel.text = "Tap to Start"
        playLabel.fontName = "Arial"
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        playLabel.name = "playLabel"
        addChild(playLabel)
        
        livesLabel.fontSize = 18
        livesLabel.fontColor = .black
        livesLabel.fontName = "Arial"
        livesLabel.position = CGPoint(x: frame.minX + 50, y: frame.minY + 18)
        addChild(playLabel)
        
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = .black
        scoreLabel.fontName = "Arial"
        scoreLabel.position = CGPoint(x: frame.maxX -  50, y: frame.minY + 18)
        addChild(scoreLabel)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        for touch in touches {
            let location = touch.location(in: self)
            if playingGame {
                paddle.position.x = location.x
            }
            else {
                for node in nodes(at: location) {
                    if node.name == "playLabel" {
                        playingGame = true
                        node.alpha = 0
                        score = 3
                        lives = 0
                        updateLabels()
                        kickBall()
                    }
                }
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        for touch in touches {
            let location = touch.location(in: self)
            if playingGame {
                paddle.position.x = location.x
            }
            }
        }
            func didBegin(_ contact: SKPhysicsContact) {
            for brick in bricks {
                if (contact.bodyA.node == brick || contact.bodyB.node == brick),
                   (contact.bodyA.node == ball || contact.bodyB.node == ball ||
                    contact.bodyA.node == ball2 || contact.bodyB.node == ball2) {
                    
                        score += 1
                        ball.physicsBody!.velocity.dx *= CGFloat(1.02)
                        ball.physicsBody!.velocity.dy *= CGFloat(1.02)
                        updateLabels()
                        if brick.color == .blue {
                            brick.color = .orange
                        }
                        else if brick.color == .orange {
                            brick.color = .green
                        }
                        else {
                            brick.removeFromParent()
                            removedBricks += 1
                            if removedBricks == bricks.count {
                                gameOver(winner: true)
                            }
                        }
                    }
                }
                if (contact.bodyA.node == ball || contact.bodyB.node == ball ||
                    contact.bodyA.node == ball2 || contact.bodyB.node == ball2),
                   (contact.bodyA.node?.name == "loseZone" || contact.bodyB.node?.name == "loseZone") {
                    gameOver(winner: false)
                }
            }
    func gameOver(winner: Bool) {
        playingGame = false
        playLabel.alpha = 1
        resetGame()
        if winner {
            playLabel.text = "You win! Tap to play again"
        }
        else {
            playLabel.text = "You lose! Tap to play again"
        }
    }
    func makeBricks() {
        for brick in bricks {
            if brick.parent != nil {
                brick.removeFromParent()
            }
        }
        bricks.removeAll()
        removedBricks = 0
        
        let count = Int(frame.width) / 55
        let xOffset = (Int(frame.width) - (count * 55)) / 2 + Int(frame.minX) + 25
        let y = Int(frame.maxY) - 65
        for i in 0..<count {
            let x = i * 55 + xOffset
            makeBrick(x: x, y: y, color: .green)
        }
    }
    override func update(_ currentTime: TimeInterval) {
        if abs(ball.physicsBody!.velocity.dx) < 100 {
            ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -3...3), dy: 0))
        }
        if abs(ball.physicsBody!.velocity.dy) < 100 {
            ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: Int.random(in: -3...3)))
        }
    }
    }

