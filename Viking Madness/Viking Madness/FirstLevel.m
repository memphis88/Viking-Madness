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

typedef NS_OPTIONS(uint32_t, VMPhysicsCategory)
{
    VMPhysicsCategoryTerrain    = 1 << 0,
    VMPhysicsCategoryBaelog     = 1 << 1,
    VMPhysicsCategoryCamera     = 1 << 2,
    VMPhysicsCategoryKnight     = 1 << 3,
};

@interface FirstLevel () <SKPhysicsContactDelegate>

@end

@implementation FirstLevel
{
    SKSpriteNode *_background;
    SKSpriteNode *_level;
    
    SKNode *_bgLayer;
    SKNode *_playerLayer;
    SKNode *_userInterface;
    SKNode *_cameraFrame;
    Baelog *_baelog;
    Knight *_knight;
    
    int _debug;
    NSArray *_debugArray;
    NSArray *_debugKnight;
    
    NSTimeInterval _dt;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _idleTime;
    
    SKSpriteNode *_up;
    SKSpriteNode *_down;
    SKSpriteNode *_left;
    SKSpriteNode *_right;
    SKSpriteNode *_jump;
    
    SKAction *_walkRightAnimation;
    SKAction *_idleAnimation;
    SKAction *_walkLeftAnimation;
    SKAction *_idleLeftAnimation;
    
    BOOL _idle;
    BOOL _midAir;
    CGPoint _velocity;
    int _currentSlice;
}

#pragma mark Overriden methods

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self initBackground];
        [self initTerrain];
        
        [self initEntities];
        
        [self initCameraFrame];
        [self initUserInterface];
        
        [self initActions];
        
        _velocity = CGPointZero;
        _idleTime = 0;
        _idle = NO;
        _midAir = NO;
        
        //Debuging
        _debug = 0;
        _debugArray = @[@"walk",
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
                         @"slashRight"];
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
    
    if (_idleTime > 5.0 && !_idle) {
        _idle = YES;
        if (_baelog.rightDirection) {
            [_baelog runAction:[SKAction repeatActionForever:_idleAnimation] withKey:@"idleAnimation"];
        }
        else
        {
            [_baelog runAction:[SKAction repeatActionForever:_idleLeftAnimation] withKey:@"idleLeftAnimation"];
        }
        
    }
    [self moveSprite:_baelog velocity:_velocity];
    [self dummyCamera];
}

#pragma mark Initializers

-(void)initBackground
{
    _bgLayer = [SKNode node];
    [self addChild:_bgLayer];
    _background = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:self.size];
    _background.anchorPoint = CGPointZero;
    _background.position = CGPointZero;
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.contactDelegate = self;
    
    
    [_bgLayer addChild:_background];
}

-(void)initEntities
{
    _playerLayer = [SKNode node];
    [self addChild:_playerLayer];
    
    _baelog = [[Baelog alloc] initWithPosition:CGPointMake(self.size.width/2, 450)];
    _baelog.rightDirection = YES;
    _knight = [[Knight alloc] initWithPosition:CGPointMake(self.size.width/2 + 150, 450)];
    
    CGSize baelogPB = CGSizeMake(_baelog.size.width - 12, _baelog.size.height - 7);
    _baelog.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:baelogPB];
    _baelog.physicsBody.categoryBitMask = VMPhysicsCategoryBaelog;
    _baelog.physicsBody.collisionBitMask = VMPhysicsCategoryTerrain;
    _baelog.physicsBody.contactTestBitMask = VMPhysicsCategoryTerrain;
    _baelog.physicsBody.restitution = 0.0;
    
    CGSize knightPB = CGSizeMake(_knight.size.width - 25, _knight.size.height - 8);
    _knight.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:knightPB];
    _knight.physicsBody.categoryBitMask = VMPhysicsCategoryKnight;
    _knight.physicsBody.collisionBitMask = VMPhysicsCategoryTerrain;
    
    /*
     *debuging frames
     */
    
    [_baelog attachDebugRectWithSize:baelogPB];
    [_knight attachDebugRectWithSize:knightPB];
    
    [_baelog setScale:3.0];
    [_knight setScale:2.0];
    
    [_playerLayer addChild:_baelog];
    [_playerLayer addChild:_knight];
}

-(void)initTerrain
{
    _currentSlice = 0;
    _level = [SKSpriteNode spriteNodeWithImageNamed:@"level1-0-0.png"];
    _level.name = @"bg";
    _level.anchorPoint = CGPointZero;
    _level.position = CGPointZero;
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"level1_collision_data" ofType:@"plist"];
    NSDictionary *collisionDataDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSArray *collisionData = collisionDataDictionary[@"path_0"];
    CGMutablePathRef collisionPath = CGPathCreateMutable();
    
    for (NSArray *objects in collisionData) {
        for (int i = 0; i < objects.count; i++) {
            NSString *path = objects[i];
            CGPoint point = CGPointFromString(path);
            if (i == 0) {
                CGPathMoveToPoint(collisionPath, nil, point.x, point.y);
            }
            else
            {
                CGPathAddLineToPoint(collisionPath, nil, point.x, point.y);
            }
        }
    }
    
    CGPathCloseSubpath(collisionPath);
    
    _level.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:collisionPath];
    _level.physicsBody.dynamic = NO;
    _level.physicsBody.categoryBitMask = VMPhysicsCategoryTerrain;
    _level.physicsBody.collisionBitMask = VMPhysicsCategoryBaelog;
    _level.physicsBody.contactTestBitMask = VMPhysicsCategoryBaelog;
    _level.physicsBody.restitution = 0.0;
    [_level attachDebugFrameFromPath:collisionPath];
    CGPathRelease(collisionPath);
    
    [_bgLayer addChild:_level];
    
    SKSpriteNode *levelContinued = [SKSpriteNode spriteNodeWithImageNamed:@"level1-0-1.png"];
    levelContinued.name = @"bg";
    levelContinued.anchorPoint = CGPointZero;
    levelContinued.position = CGPointMake(_level.size.width, 0);
    
    collisionData = collisionDataDictionary[@"path_1"];
    collisionPath = CGPathCreateMutable();
    
    for (NSArray *objects in collisionData) {
        for (int i = 0; i < objects.count; i++) {
            NSString *path = objects[i];
            CGPoint point = CGPointFromString(path);
            if (i == 0) {
                CGPathMoveToPoint(collisionPath, nil, point.x, point.y);
            }
            else
            {
                CGPathAddLineToPoint(collisionPath, nil, point.x, point.y);
            }
        }
    }
    
    CGPathCloseSubpath(collisionPath);
    
    levelContinued.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:collisionPath];
    levelContinued.physicsBody.dynamic = NO;
    levelContinued.physicsBody.categoryBitMask = VMPhysicsCategoryTerrain;
    levelContinued.physicsBody.collisionBitMask = VMPhysicsCategoryBaelog;
    levelContinued.physicsBody.contactTestBitMask = VMPhysicsCategoryBaelog;
    levelContinued.physicsBody.restitution = 0.0;
    [levelContinued attachDebugFrameFromPath:collisionPath];
    CGPathRelease(collisionPath);
    
    [_bgLayer addChild:levelContinued];
}

-(void)initCameraFrame
{
    _cameraFrame = [SKNode node];
    [self addChild:_cameraFrame];
    
    CGSize frame = CGSizeMake(self.size.width - 512, _baelog.size.height);
    SKSpriteNode *cFrame = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor] size:frame];
    cFrame.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:cFrame.frame];
    cFrame.physicsBody.dynamic = NO;
    cFrame.physicsBody.categoryBitMask = VMPhysicsCategoryCamera;
    cFrame.physicsBody.collisionBitMask = 0;
    cFrame.physicsBody.contactTestBitMask = VMPhysicsCategoryBaelog;
    cFrame.anchorPoint = CGPointMake(0.5, 0);
    cFrame.position = CGPointMake(_baelog.position.x + _baelog.size.width/2, _baelog.position.y);
    [cFrame attachDebugRectWithSize:frame];
    [_cameraFrame addChild:cFrame];
    
    
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
    
    
    [_userInterface addChild:_up];
    [_userInterface addChild:_down];
    [_userInterface addChild:_left];
    [_userInterface addChild:_right];
    [_userInterface addChild:_jump];
    
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

#pragma mark Touch events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UITouch *touch = [touches anyObject];
    //CGPoint touchLocation = [touch locationInNode:_bgLayer];
    //[self dummyAnimationDebug];
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:location];
    for (SKNode *node in nodes) {
        //go through nodes, get the zPosition if you want
        //int nodePos = node.zPosition;
        
        //or check the node against your nodes
        if ([node.name isEqualToString:@"right"]) {
            //self moveSprite:_baelog velocity:(CGPoint)
            _right.color = [SKColor yellowColor];
            _right.colorBlendFactor = 1.0;
            _velocity = CGPointMake(self.size.width/3, 0);
            _baelog.rightDirection = YES;
            [self moveBaelogRight];
            continue;
        }
        if ([node.name isEqualToString:@"left"]) {
            //self moveSprite:_baelog velocity:(CGPoint)
            _right.color = [SKColor yellowColor];
            _right.colorBlendFactor = 1.0;
            _velocity = CGPointMake(-self.size.width/3, 0);
            _baelog.rightDirection = NO;
            [self moveBaelogLeft];
            continue;
        }
        if ([node.name isEqualToString:@"jump"] && !_midAir) {
            [self jumpBaelog];
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
        _idleTime = 0;
        _idle = NO;
        _right.colorBlendFactor = 1.0;
        [self moveBaelogRight];
    }
    else if (!_baelog.rightDirection && touched) {
        _idleTime = 0;
        _idle = NO;
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
        //go through nodes, get the zPosition if you want
        //int nodePos = node.zPosition;
        
        //or check the node against your nodes
        if ([node.name isEqualToString:@"right"]) {
            continue;
        } else if ([node.name isEqualToString:@"left"]) {
            continue;
        }
        else {
            //_right.colorBlendFactor = 0;
            
            [self stopBaelog];
        }
    }
    
}

#pragma mark Movement

- (void)moveSprite:(SKSpriteNode *)sprite
          velocity:(CGPoint)velocity
{
    
    //CGPoint normalized = CGPointNormalize(velocity);
    
    // 1
    
    CGPoint amountToMove = CGPointMultiplyScalar(velocity, _dt);
    //NSLog(@"Amount to move: %@", NSStringFromCGPoint(amountToMove));
    
    // 2
    sprite.position = CGPointAdd(sprite.position, amountToMove);
    
}

-(void)moveBaelogRight
{
    _velocity = CGPointMake(self.size.width/3, 0);
    if (_midAir) {
        return;
    }
    if (![_baelog actionForKey:@"walkRightAnimation"]) {
        [_baelog removeActionForKey:@"idleAnimation"];
        [_baelog removeActionForKey:@"idleLeftAnimation"];
        _idle = NO;
        _idleTime = 0;
        [_baelog runAction:[SKAction repeatActionForever:_walkRightAnimation] withKey:@"walkRightAnimation"];
    }
}

-(void)moveBaelogLeft
{
    _velocity = CGPointMake(-self.size.width/3, 0);
    if (_midAir) {
        return;
    }
    if (![_baelog actionForKey:@"walkLeftAnimation"]) {
        [_baelog removeActionForKey:@"idleAnimation"];
        [_baelog removeActionForKey:@"idleLeftAnimation"];
        _idle = NO;
        _idleTime = 0;
        [_baelog runAction:[SKAction repeatActionForever:_walkLeftAnimation] withKey:@"walkLeftAnimation"];
    }
}

-(void)stopBaelog
{
    _velocity = CGPointZero;
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
    _midAir = YES;
    _idle = NO;
    _idleTime = 0;
    [_baelog.physicsBody applyImpulse:CGVectorMake(0, 20)];
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

-(void)cameraMove
{
    CGPoint scrollVelocity = CGPointMake(self.size.width/3, 0);
    [self moveSprite:_background velocity:scrollVelocity];
}

-(void)terrainPreparation
{
    [_bgLayer enumerateChildNodesWithName:@"bg" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *bg = (SKSpriteNode *)node;
        CGPoint bgScreenPos = [_bgLayer convertPoint:bg.position toNode:self];
        if (bgScreenPos.x <= -bg.size.width) {
            
        }
    }];
}

#pragma mark Physics & Collisions

-(BOOL)collidesWithSurface:(SKSpriteNode *)sprite
{
    
    return NO;
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    if (collision == (VMPhysicsCategoryTerrain | VMPhysicsCategoryBaelog)) {
        _midAir = NO;
        if (_baelog.rightDirection) {
            [_baelog runAction:[SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"frame"] timePerFrame:0]];
        }
        else
        {
            [_baelog runAction:[SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"frameLeft"] timePerFrame:0]];
        }
    }
    if (collision == (VMPhysicsCategoryBaelog | VMPhysicsCategoryCamera)) {
        //[self cameraMove];
    }
}

#pragma mark Debuging

-(void)dummyAnimationDebug
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
    
}

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
