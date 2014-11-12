//
//  FirstLevel.m
//  Viking Madness
//
//  Created by Dionysios Kakouris on 22/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import "FirstLevel.h"
#import "Baelog.h"
#import "Knight.h"
#import "SKSpriteNode+DebugDraw.h"
#import "JSTileMap.h"

typedef NS_OPTIONS(uint32_t, VMPhysicsCategory)
{
    VMPhysicsCategoryTerrain    = 1 << 0,
    VMPhysicsCategoryBaelog     = 1 << 1,
    VMPhysicsCategoryCamera     = 1 << 2,
    VMPhysicsCategoryKnight     = 1 << 3,
};

static inline CGPoint CGPointToActualCoords(const CGPoint start, const CGPoint point)
{
    return CGPointMake(start.x + point.x, start.y - point.y);
}

static inline CGPoint CGPointFromStringArray(NSArray *string, const NSString *relX, const NSString *relY)
{
    CGFloat x = [string[0] floatValue];
    CGFloat y = [string[1] floatValue];
    CGFloat sx = [relX floatValue];
    CGFloat sy = [relY floatValue];
    return CGPointToActualCoords(CGPointMake(sx, sy), CGPointMake(x, y));
}

static const float BAELOG_MOVEMENT_SPEED = 1024/8;

@interface FirstLevel () <SKPhysicsContactDelegate>

@end

@implementation FirstLevel
{
    SKSpriteNode *_background;
    SKSpriteNode *_cameraFrame;
    SKSpriteNode *_level;
    
    JSTileMap *_terrainMap;
    
    SKNode *_bgLayer;
    SKNode *_playerLayer;
    SKNode *_userInterface;
    
    Baelog *_baelog;
    Knight *_knight;
    
    int _debug;
    NSMutableArray *_enemies;
    
    NSTimeInterval _dt;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _idleTime;
    
    SKSpriteNode *_up;
    SKSpriteNode *_down;
    SKSpriteNode *_left;
    SKSpriteNode *_right;
    SKSpriteNode *_jump;
    SKSpriteNode *_punch;
    SKSpriteNode *_swing;
    
    SKAction *_walkRightAnimation;
    SKAction *_walkLeftAnimation;
    SKAction *_idleAnimation;
    SKAction *_idleLeftAnimation;
    SKAction *_fallAnimation;
    SKAction *_fallLeftAnimation;
    SKAction *_punchAnimation;
    SKAction *_punchLeftAnimation;
    SKAction *_swingAnimation;
    SKAction *_swingLeftAnimation;
    
    BOOL _idle;
    BOOL _midAir;
    BOOL _moves;
    CGPoint _velocity;
    int _currentSlice;
    CGPoint _camera;
}

#pragma mark Frame initilization and cycle

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        _enemies = [[NSMutableArray alloc] init];
        
        [self initBackground];
        [self initTMXMap];
        [self initEntities];
        [self initUserInterface];
        [self initActions];
        
        _velocity = CGPointZero;
        _idleTime = 0;
        _currentSlice = 0;
        _idle = NO;
        _midAir = NO;
        _moves = NO;
        
        //Debugging
        _debug = 0;
        /*_debugArray = @[@"walk",
                        @"climb",
                        @"pushObject",
                        @"idle",
                        @"fall",
                        @"swordSwing",
                        @"pushObject",
                        @"struck",
                        @"idle2",
                        @"idle3",
                        @"directPunch",
                        @"pushUp",
                        @"hang"];
        _debugKnight = @[@"walkLeft",
                         @"walkRight",
                         @"slashLeft",
                         @"slashRight"];*/
    }
    
    return self;
}

-(void)update:(NSTimeInterval)currentTime
{
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    _idleTime += _dt;
    
    [_playerLayer enumerateChildNodesWithName:@"knight" usingBlock:^(SKNode *node, BOOL *stop) {
        Knight *knight = (Knight *)node;
        [knight update:_dt];
    }];
    
    [self determineMidAir];
    [self fallBaelog];
    [self idleBaelog];
    [self makeCameraMovementVector];
    [self moveSprite:_baelog velocity:_velocity];
}

-(void)didSimulatePhysics
{
    [self moveCamera];
}

-(void)didEvaluateActions
{
    [_playerLayer enumerateChildNodesWithName:@"knight" usingBlock:^(SKNode *node, BOOL *stop) {
        Knight *knight = (Knight *)node;
        [knight didEvaluateActions];
        knight.hostilePosition = _baelog.position;
    }];
}

#pragma mark Initializers

-(void)initBackground
{
    _bgLayer = [SKNode node];
    self.scaleMode = SKSceneScaleModeResizeFill;
    _bgLayer.scene.scaleMode = SKSceneScaleModeResizeFill;
    [self addChild:_bgLayer];
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
    _background.anchorPoint = CGPointZero;
    _background.position = CGPointZero;
    _background.zPosition = - 60.0;
    //self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.contactDelegate = self;
    
    [self addChild:_background];
}

-(void)initTMXMap
{
    _terrainMap = [JSTileMap mapNamed:@"level1.tmx"];
    _terrainMap.scene.scaleMode = SKSceneScaleModeResizeFill;
    if (_terrainMap) {
        [_bgLayer addChild:_terrainMap];
        [_bgLayer setScale:2.0];
        NSMutableArray *physicsBodies = [[NSMutableArray alloc] init];
        NSArray *allObjects = _terrainMap.objectGroups;
        for (TMXObjectGroup *objLayer in allObjects) {
            NSArray *terrainObjects = [objLayer objectsNamed:@"terrain"];
            CGMutablePathRef polygon;
            for (NSDictionary *terrain in terrainObjects) {
                polygon = CGPathCreateMutable();
                NSString *coords = [terrain objectForKey:@"polylinePoints"];
                NSString *startx = [terrain objectForKey:@"x"];
                NSString *starty = [terrain objectForKey:@"y"];
                CGPathMoveToPoint(polygon, nil, [startx floatValue], [starty floatValue]);
                NSArray *couple = [coords componentsSeparatedByString:@" "];
                for (NSString *xyJoined in couple) {
                    NSArray *xy = [xyJoined componentsSeparatedByString:@","];
                    CGPoint final = CGPointFromStringArray(xy, startx, starty);
                    CGPathAddLineToPoint(polygon, nil, final.x, final.y);
                }
                CGPathCloseSubpath(polygon);
                SKSpriteNode *test = [SKSpriteNode spriteNodeWithTexture:nil];
                [test attachDebugFrameFromPath:polygon];
                [_bgLayer addChild:test];
                [physicsBodies addObject:[SKPhysicsBody bodyWithEdgeLoopFromPath:polygon]];
                CGPathRelease(polygon);
            }
        }
        
        
        _terrainMap.physicsBody = [SKPhysicsBody bodyWithBodies:physicsBodies];
        _terrainMap.physicsBody.dynamic = NO;
        _terrainMap.physicsBody.categoryBitMask = VMPhysicsCategoryTerrain;
        _terrainMap.physicsBody.collisionBitMask = VMPhysicsCategoryBaelog;
        _terrainMap.physicsBody.contactTestBitMask = VMPhysicsCategoryBaelog;
        _terrainMap.physicsBody.restitution = 0.0;
        _terrainMap.physicsBody.friction = 1.0;
    }
}

-(void)initEntities
{
    _playerLayer = [SKNode node];
    [_bgLayer addChild:_playerLayer];
    
    _baelog = [[Baelog alloc] initWithPosition:CGPointMake(self.size.width/4, 250)];
    _baelog.rightDirection = YES;
    _knight = [[Knight alloc] initWithPosition:CGPointMake(self.size.width/4 + 150, 250)];
    
    CGSize baelogPB = CGSizeMake(_baelog.size.width - 12, _baelog.size.height - 7);
    _baelog.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:baelogPB];
    _baelog.physicsBody.categoryBitMask = VMPhysicsCategoryBaelog;
    _baelog.physicsBody.collisionBitMask = VMPhysicsCategoryTerrain | VMPhysicsCategoryCamera;
    _baelog.physicsBody.contactTestBitMask = VMPhysicsCategoryTerrain | VMPhysicsCategoryKnight;
    _baelog.physicsBody.restitution = 0.0;
    _baelog.physicsBody.friction = 1.0;
    _baelog.physicsBody.allowsRotation = NO;
    _baelog.physicsBody.angularVelocity = 0;
    
    NSArray *allObjects = _terrainMap.objectGroups;
    CGSize knightPB = CGSizeMake(_knight.size.width - 25, _knight.size.height - 8);
    for (TMXObjectGroup *objLayer in allObjects) {
        NSArray *enemySpawnObjects = [objLayer objectsNamed:@"enemySpawn"];
        for (NSDictionary *enemySpawn in enemySpawnObjects) {
            Knight *knight = [[Knight alloc] initWithPosition:CGPointMake([[enemySpawn objectForKey:@"x"] floatValue] + knightPB.width/2,
                                                                          [[enemySpawn objectForKey:@"y"] floatValue] + knightPB.height/2)];
            knight.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:knightPB];
            knight.physicsBody.categoryBitMask = VMPhysicsCategoryKnight;
            knight.physicsBody.collisionBitMask = VMPhysicsCategoryTerrain;
            knight.physicsBody.contactTestBitMask = VMPhysicsCategoryBaelog;
            knight.physicsBody.allowsRotation = NO;
            knight.physicsBody.angularVelocity = 0;
            
            knight.patrolWidth = [enemySpawn objectForKey:@"width"];
            [knight attachDebugRectWithSize:knightPB];
            [knight setScale:0.8];
            knight.enemy = _baelog;
            [_enemies addObject:knight];
            [_playerLayer addChild:knight];
            [knight startPatrol];
        }
    }
    
    _knight.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:knightPB];
    _knight.physicsBody.categoryBitMask = VMPhysicsCategoryKnight;
    _knight.physicsBody.collisionBitMask = VMPhysicsCategoryTerrain;
    _knight.physicsBody.allowsRotation = NO;
    _knight.physicsBody.angularVelocity = 0;
    
    /*
     *debuging frames
     */
    
    [_baelog attachDebugRectWithSize:baelogPB];
    [_knight attachDebugRectWithSize:knightPB];
    
    [_baelog setScale:1.2];
    [_knight setScale:0.8];
    
    [_playerLayer addChild:_baelog];
    //[_playerLayer addChild:_knight];
}

-(void)initActions
{
    SKAction *blink = [SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"idle"] timePerFrame:0.1];
    SKAction *strafe = [SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"idle2"] timePerFrame:0.1];
    SKAction *taunt = [SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"idle3"] timePerFrame:0.1];
    _idleAnimation = [SKAction sequence:@[blink,
                                [SKAction waitForDuration:3.0],
                                blink,
                                [SKAction waitForDuration:2.0],
                                strafe,
                                [SKAction waitForDuration:0.5],
                                taunt]];
    
    blink = [SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"idleLeft"] timePerFrame:0.1];
    strafe = [SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"idle2Left"] timePerFrame:0.1];
    taunt = [SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"idle3Left"] timePerFrame:0.1];
    _idleLeftAnimation = [SKAction sequence:@[blink,
                                              [SKAction waitForDuration:3.0],
                                              blink,
                                              [SKAction waitForDuration:2.0],
                                              strafe,
                                              [SKAction waitForDuration:0.5],
                                              taunt]];
    
    _walkRightAnimation = [self animateBaelogWithKey:@"walk"];
    _walkLeftAnimation = [self animateBaelogWithKey:@"walkLeft"];
    _fallAnimation = [self animateBaelogWithKey:@"fall"];
    _fallLeftAnimation = [self animateBaelogWithKey:@"fallLeft"];
    _punchAnimation = [self animateBaelogWithKey:@"directPunch"];
    _punchLeftAnimation = [self animateBaelogWithKey:@"directPunchLeft"];
    _swingAnimation = [self animateBaelogWithKey:@"swordSwing"];
    _swingLeftAnimation = [self animateBaelogWithKey:@"swordSwingLeft"];
}

-(void)initUserInterface
{
    _userInterface = [SKNode node];
    [self addChild:_userInterface];
    
    _up = [SKSpriteNode spriteNodeWithImageNamed:@"up.png"];
    _up.name = @"up";
    _up.anchorPoint = CGPointZero;
    _up.yScale = 0.6;
    _up.xScale = 0.6;
    _up.position = CGPointMake(_up.size.width, _up.size.height * 2 + _down.size.height);
    
    _down = [SKSpriteNode spriteNodeWithImageNamed:@"down.png"];
    _down.name = @"down";
    _down.yScale = 0.6;
    _down.xScale = 0.6;
    _down.anchorPoint = CGPointZero;
    _down.position = CGPointMake(_up.size.width, 0);
    
    _left = [SKSpriteNode spriteNodeWithImageNamed:@"left.png"];
    _left.name = @"left";
    _left.yScale = 0.6;
    _left.xScale = 0.6;
    _left.anchorPoint = CGPointZero;
    _left.position = CGPointMake(0, _down.size.height);
    
    _right = [SKSpriteNode spriteNodeWithImageNamed:@"right.png"];
    _right.name = @"right";
    _right.yScale = 0.6;
    _right.xScale = 0.6;
    _right.anchorPoint = CGPointZero;
    _right.position = CGPointMake(_left.size.width + _down.size.width, _down.size.height);
    
    _right.color = [SKColor redColor];
    _right.colorBlendFactor = 1.0;
    
    _jump = [SKSpriteNode spriteNodeWithImageNamed:@"circle_grey.png"];
    _jump.name = @"jump";
    _jump.yScale = 0.4;
    _jump.xScale = 0.4;
    _jump.position = CGPointMake(self.size.width - _jump.frame.size.width/2, _jump.frame.size.height/2);
    
    _punch = [SKSpriteNode spriteNodeWithImageNamed:@"circle_grey.png"];
    _punch.name = @"punch";
    _punch.yScale = 0.4;
    _punch.xScale = 0.4;
    _punch.position = CGPointMake(self.size.width - 1.5 * _jump.frame.size.width, _jump.frame.size.height/2);
    
    _swing = [SKSpriteNode spriteNodeWithImageNamed:@"circle_grey.png"];
    _swing.name = @"swing";
    _swing.yScale = 0.4;
    _swing.xScale = 0.4;
    _swing.position = CGPointMake(self.size.width - _jump.frame.size.width/2, 1.5 * _jump.frame.size.height);
    
    
    [_userInterface addChild:_up];
    [_userInterface addChild:_down];
    [_userInterface addChild:_left];
    [_userInterface addChild:_right];
    [_userInterface addChild:_jump];
    [_userInterface addChild:_punch];
    [_userInterface addChild:_swing];
    
}

#pragma mark Animation

-(SKAction *)animateBaelogWithKey:(NSString *)key
{
    SKAction *action;
    action = [SKAction animateWithTextures:[_baelog animationTexturesWithKey:key] timePerFrame:0.1];
    return action;
}

-(SKAction *)animateKnightWithKey:(NSString *)key
{
    SKAction *action;
    action = [SKAction animateWithTextures:[_knight animationTexturesWithKey:key] timePerFrame:0.1];
    return action;
}

-(void)idleBaelog
{
    if (_idleTime > 5.0 && !_idle &&!_moves) {
        _idle = YES;
        if (_baelog.rightDirection) {
            [_baelog runAction:[SKAction repeatActionForever:_idleAnimation] withKey:@"idleAnimation"];
        }
        else
        {
            [_baelog runAction:[SKAction repeatActionForever:_idleLeftAnimation] withKey:@"idleLeftAnimation"];
        }
        
    }
}

-(void)fallBaelog
{
    if (_midAir) {
        if (_baelog.physicsBody.velocity.dy < 0) {
            if (![_baelog actionForKey:@"fallRightAnimation"] && ![_baelog actionForKey:@"fallLeftAnimation"]) {
                [_baelog removeAllActions];
                if (_baelog.rightDirection) {
                    [_baelog runAction:[SKAction repeatActionForever:_fallAnimation] withKey:@"fallRightAnimation"];
                }
                else
                {
                    [_baelog runAction:[SKAction repeatActionForever:_fallLeftAnimation] withKey:@"fallLeftAnimation"];
                }
            }
        }
    }
}

-(void)punchBaelog
{
    if (!_midAir) {
        if (_moves) {
            [self stopBaelog];
        }
        if (![_baelog actionForKey:@"punchLeft"] && ![_baelog actionForKey:@"punchRight"]) {
            [_baelog removeAllActions];
            if (_baelog.rightDirection) {
                [_baelog runAction:[SKAction sequence:@[_punchAnimation,
                                                        [SKAction runBlock:^{
                    [self stopBaelog];
                }]]] withKey:@"punchRight"];
            }
            else
            {
                [_baelog runAction:[SKAction sequence:@[_punchLeftAnimation,
                                                        [SKAction runBlock:^{
                    [self stopBaelog];
                }]]] withKey:@"punchLeft"];
            }
            [_baelog dealDamage:_enemies attackType:Punch];
        }
    }
}

-(void)swingBaelog
{
    if (!_midAir) {
        if (_moves) {
            [self stopBaelog];
        }
        if (![_baelog actionForKey:@"swingLeft"] && ![_baelog actionForKey:@"swingRight"]) {
            [_baelog removeAllActions];
            if (_baelog.rightDirection) {
                [_baelog runAction:[SKAction sequence:@[_swingAnimation,
                                                        [SKAction runBlock:^{
                    [self stopBaelog];
                }]]] withKey:@"swingRight"];
            }
            else
            {
                [_baelog runAction:[SKAction sequence:@[_swingLeftAnimation,
                                                        [SKAction runBlock:^{
                    [self stopBaelog];
                }]]] withKey:@"swingLeft"];
            }
            [_baelog dealDamage:_enemies attackType:Slash];
        }
    }
}

#pragma mark Touch events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:location];
    for (SKNode *node in nodes) {
        if ([node.name isEqualToString:@"right"]) {
            _right.color = [SKColor yellowColor];
            _right.colorBlendFactor = 1.0;
            _velocity = CGPointMake(BAELOG_MOVEMENT_SPEED, 0);
            _baelog.rightDirection = YES;
            [self moveBaelogRight];
            continue;
        }
        if ([node.name isEqualToString:@"left"]) {
            _right.color = [SKColor yellowColor];
            _right.colorBlendFactor = 1.0;
            _velocity = CGPointMake(-BAELOG_MOVEMENT_SPEED, 0);
            _baelog.rightDirection = NO;
            [self moveBaelogLeft];
            continue;
        }
        if ([node.name isEqualToString:@"jump"] && !_midAir) {
            [self jumpBaelog];
        }
        if ([node.name isEqualToString:@"punch"] && !_midAir) {
            [self punchBaelog];
        }
        if ([node.name isEqualToString:@"swing"] && !_midAir) {
            [self swingBaelog];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:location];
    BOOL touched = NO;
    for (SKNode *node in nodes) {
        if ([node.name isEqualToString:@"right"]) {
            _baelog.rightDirection = YES;
            touched = YES;
            continue;
        } else if ([node.name isEqualToString:@"left"]) {
            _baelog.rightDirection = NO;
            touched = YES;
            continue;
        }
    }
    if (_baelog.rightDirection && touched) {
        _right.colorBlendFactor = 1.0;
        [self moveBaelogRight];
    }
    else if (!_baelog.rightDirection && touched) {
        _right.colorBlendFactor = 1.0;
        [self moveBaelogLeft];
    }
    else
    {
        [self stopBaelog];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:location];
    for (SKNode *node in nodes) {
        if ([node.name isEqualToString:@"right"]) {
            [self stopBaelog];
        } else if ([node.name isEqualToString:@"left"]) {
            [self stopBaelog];
        }
        else {
            
        }
    }
    
}

#pragma mark Movement

- (void)moveSprite:(SKNode *)sprite
          velocity:(CGPoint)velocity
{
    CGPoint amountToMove = CGPointMultiplyScalar(velocity, _dt);
    sprite.position = CGPointAdd(sprite.position, amountToMove);

}

-(void)moveBaelogRight
{
    _velocity = CGPointMake(BAELOG_MOVEMENT_SPEED, 0);
    _moves = YES;
    if (_midAir) {
        return;
    }
    if (![_baelog actionForKey:@"walkRightAnimation"] &&
        ![_baelog actionForKey:@"jumpAnimation"] &&
        ![_baelog actionForKey:@"jumpLeftAnimation"] &&
        ![_baelog actionForKey:@"fallAnimation"] &&
        ![_baelog actionForKey:@"fallLeftAnimation"])
    {
        [_baelog removeAllActions];
        _idle = NO;
        _idleTime = 0;
        [_baelog runAction:[SKAction repeatActionForever:_walkRightAnimation] withKey:@"walkRightAnimation"];
    }
}

-(void)moveBaelogLeft
{
    _velocity = CGPointMake(-BAELOG_MOVEMENT_SPEED, 0);
    _moves = YES;
    if (_midAir) {
        return;
    }
    if (![_baelog actionForKey:@"walkLeftAnimation"] &&
        ![_baelog actionForKey:@"jumpAnimation"] &&
        ![_baelog actionForKey:@"jumpLeftAnimation"] &&
        ![_baelog actionForKey:@"fallAnimation"] &&
        ![_baelog actionForKey:@"fallLeftAnimation"])
    {
        [_baelog removeAllActions];
        _idle = NO;
        _idleTime = 0;
        [_baelog runAction:[SKAction repeatActionForever:_walkLeftAnimation] withKey:@"walkLeftAnimation"];
    }
}

-(void)stopBaelog
{
    _velocity = CGPointZero;
    _moves = NO;
    if (_midAir) {
        return;
    }
    [_baelog removeAllActions];
    if (_baelog.rightDirection) {
        [_baelog runAction:[SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"frame"] timePerFrame:0]];
    }
    else
    {
        [_baelog runAction:[SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"frameLeft"] timePerFrame:0]];
    }
}

-(void)jumpBaelog
{
    _idle = NO;
    _idleTime = 0;
    [_baelog.physicsBody applyImpulse:CGVectorMake(0, 17)];
    [_baelog removeAllActions];
    if (_baelog.rightDirection) {
        [_baelog runAction:[self animateBaelogWithKey:@"jump"] withKey:@"jumpAnimation"];
    }
    else
    {
        [_baelog runAction:[self animateBaelogWithKey:@"jumpLeft"] withKey:@"jumpLeftAnimation"];
    }
    
}

#pragma mark Camera

-(void)makeCameraMovementVector
{
    CGPoint relativePoint = [_playerLayer convertPoint:_baelog.position toNode:self];
    _camera = CGPointMake(relativePoint.x - self.size.width/2, relativePoint.y - self.size.height/2);
}

-(void)moveCamera
{
    if (!CGPointEqualToPoint(_camera, CGPointZero)) {
        [_bgLayer removeAllActions];
        [self runAction:[SKAction sequence:@[[SKAction waitForDuration:0.2],
                                             [SKAction customActionWithDuration:0
                                                                    actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            CGPoint velocityVector = CGPointMultiplyScalar(_camera, -1);
            if (_bgLayer.position.y > 0 && velocityVector.y > 0)
            {
                velocityVector = CGPointMake(velocityVector.x, 0);
            }
            if (_bgLayer.position.y < -768 &&
                velocityVector.y < 0)
            {
                velocityVector = CGPointMake(velocityVector.x, 0);
            }
            if (_bgLayer.position.x > 0 && velocityVector.x > 0) {
                velocityVector = CGPointMake(0, velocityVector.y);
            }
            if (_bgLayer.position.x < -11776//(_terrainMap.mapSize.width - self.size.width)
                && velocityVector.x < 0)
            {
                velocityVector = CGPointMake(0, velocityVector.y);
            }
            [self moveSprite:_bgLayer velocity:velocityVector];
            CGPoint unit = CGPointMake(_terrainMap.mapSize.width/ (6 * _background.size.width),
                                       _terrainMap.mapSize.height/ (6 * _background.size.height));
            CGPoint bgVel = CGPointMultiply(velocityVector, unit);
            [self moveSprite:_background velocity:bgVel];
        }]]]];
    }
}

#pragma mark Physics & Collisions

-(void)determineMidAir
{
    if ((_baelog.physicsBody.velocity.dy >= 0.001) || (_baelog.physicsBody.velocity.dy <= -0.001)) {
        _midAir = YES;
    }
    else
    {
        _midAir = NO;
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    if (collision == (VMPhysicsCategoryTerrain | VMPhysicsCategoryBaelog)) {
        [_baelog removeAllActions];
        if (_baelog.rightDirection) {
            [_baelog runAction:[SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"frame"] timePerFrame:0]];
            if (_moves) {
                [_baelog runAction:[SKAction repeatActionForever:_walkRightAnimation] withKey:@"walkRightAnimation"];
            }
        }
        else
        {
            [_baelog runAction:[SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"frameLeft"] timePerFrame:0]];
            if (_moves) {
                [_baelog runAction:[SKAction repeatActionForever:_walkLeftAnimation] withKey:@"walkLeftAnimation"];
            }
        }
    }
}


#pragma mark Debugging

/*-(void)dummyAnimationDebug
{
    [_baelog removeActionForKey:_debugArray[_debug]];
    [_baelog runAction:[SKAction repeatActionForever:[self animateBaelogWithKey:_debugArray[_debug]]] withKey:_debugArray[_debug]];
    if (_debug < 4) {
        [_knight removeActionForKey:_debugKnight[_debug]];
        [_knight runAction:[SKAction repeatActionForever:[self animateKnightWithKey:_debugKnight[_debug]]] withKey:_debugKnight[_debug]];
    }
    _debug++;
    if (_debug > 12) {
        _debug = 0;
    }
    
}*/

-(void)dummyCamera
{
    CGPoint bgVelocity = CGPointMake(-50, 0);
    CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity, _dt);
    _bgLayer.position = CGPointAdd(_bgLayer.position, amtToMove);
    [_bgLayer enumerateChildNodesWithName:@"bg" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *bg = (SKSpriteNode *)node;
        CGPoint bgScreenPos = [_bgLayer convertPoint:bg.position toNode:self];
        if (bgScreenPos.x <= -bg.size.width) {
            bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y);
        }
    }];
}

@end
