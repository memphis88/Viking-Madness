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
    VMPhysicsCategoryBorderUp   = 1 << 4,
    VMPhysicsCategoryBorderDown = 1 << 5,
    VMPhysicsCategoryBorderLeft = 1 << 6,
    VMPhysicsCategoryBorderRight= 1 << 7,
};

static inline CGVector CGVectorOppositeVector(const CGVector vect)
{
    return CGVectorMake(vect.dx * (-1), vect.dy * (-1));
}

static inline CGVector CGZeroVector()
{
    return CGVectorMake(0, 0);
}

static inline BOOL CGVectorCompare(const CGVector a, const CGVector b)
{
    if (a.dx == b.dy && a.dy == b.dy) {
        return YES;
    }
    return NO;
}

static const float BAELOG_MOVEMENT_SPEED = 1024/4;

@interface FirstLevel () <SKPhysicsContactDelegate>

@end

@implementation FirstLevel
{
    SKSpriteNode *_background;
    SKSpriteNode *_cameraFrame;
    SKSpriteNode *_level;
    
    SKNode *_bgLayer;
    SKNode *_playerLayer;
    SKNode *_userInterface;
    
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
    SKAction *_walkLeftAnimation;
    SKAction *_idleAnimation;
    SKAction *_idleLeftAnimation;
    SKAction *_fallAnimation;
    SKAction *_fallLeftAnimation;
    
    BOOL _idle;
    BOOL _midAir;
    BOOL _moves;
    CGPoint _velocity;
    int _currentSlice;
    CGPoint _camera;
}

#pragma mark Overriden methods

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self initBackground];
        [self initTerrain];
        [self initEntities];
        //[self initCameraFrame];
        [self initUserInterface];
        [self initActions];
        
        _velocity = CGPointZero;
        _idleTime = 0;
        _idle = NO;
        _midAir = NO;
        _moves = NO;
        
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
    
    [self determineMidAir];
    [self fallBaelog];
    [self idleBaelog];
    [self makeCamerVector];
    [self moveSprite:_baelog velocity:_velocity];
    //[self dummyCamera];
}

-(void)didSimulatePhysics
{
    if (CGPointEqualToPoint(_camera, CGPointZero)) {
        //NSLog(@"zero");
    }
    else
    {
        //NSLog(@"x:%f y:%f", _camera.x, _camera.y);
    }
    [self moveCamera];
    return;
    [self.physicsWorld enumerateBodiesAlongRayStart:CGPointMake(912, self.size.height)
                                                end:CGPointMake(912, 0)
                                         usingBlock:^(SKPhysicsBody *body, CGPoint point, CGVector normal, BOOL *stop) {
                                             if (body.categoryBitMask == VMPhysicsCategoryBaelog) {
                                                 //Right
                                                 if (_moves) {
                                                     _velocity = CGPointZero;
                                                     [self moveSprite:_bgLayer velocity:CGPointMake(-BAELOG_MOVEMENT_SPEED, 0)];
                                                     [self cameraMovedTowards:@"right"];
                                                 }
                                             }
                                         }];
    [self.physicsWorld enumerateBodiesAlongRayStart:CGPointMake(128, self.size.height)
                                                end:CGPointMake(128, 0)
                                         usingBlock:^(SKPhysicsBody *body, CGPoint point, CGVector normal, BOOL *stop) {
                                             if (body.categoryBitMask == VMPhysicsCategoryBaelog) {
                                                 //Left
                                                 if (_moves) {
                                                     _velocity = CGPointZero;
                                                     [self moveSprite:_bgLayer velocity:CGPointMake(BAELOG_MOVEMENT_SPEED, 0)];
                                                     [self cameraMovedTowards:@"left"];
                                                 }
                                             }
                                         }];
    [self.physicsWorld enumerateBodiesAlongRayStart:CGPointMake(0, 128)
                                                end:CGPointMake(self.size.width, 128)
                                         usingBlock:^(SKPhysicsBody *body, CGPoint point, CGVector normal, BOOL *stop) {
                                             if (body.categoryBitMask == VMPhysicsCategoryBaelog) {
                                                 //Down
                                                 _velocity = CGPointZero;
                                                 [self cameraMovedTowards:@"down"];
                                             }
                                         }];
    [self.physicsWorld enumerateBodiesAlongRayStart:CGPointMake(0, 640)
                                                end:CGPointMake(self.size.width, 640)
                                         usingBlock:^(SKPhysicsBody *body, CGPoint point, CGVector normal, BOOL *stop) {
                                             if (body.categoryBitMask == VMPhysicsCategoryBaelog) {
                                                 //Up
                                                 _velocity = CGPointZero;
                                                 [self cameraMovedTowards:@"up"];
                                             }
                                         }];
    
}

#pragma mark Initializers

-(void)initBackground
{
    _bgLayer = [SKNode node];
    [self addChild:_bgLayer];
    _background = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:self.size];
    _background.anchorPoint = CGPointZero;
    _background.position = CGPointZero;
    
    //self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.contactDelegate = self;
    
    [_bgLayer addChild:_background];
}

-(void)initEntities
{
    _playerLayer = [SKNode node];
    [_bgLayer addChild:_playerLayer];
    
    _baelog = [[Baelog alloc] initWithPosition:CGPointMake(self.size.width/2, 450)];
    _baelog.rightDirection = YES;
    _knight = [[Knight alloc] initWithPosition:CGPointMake(self.size.width/2 + 150, 450)];
    
    CGSize baelogPB = CGSizeMake(_baelog.size.width - 12, _baelog.size.height - 7);
    _baelog.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:baelogPB];
    _baelog.physicsBody.categoryBitMask = VMPhysicsCategoryBaelog;
    _baelog.physicsBody.collisionBitMask = VMPhysicsCategoryTerrain | VMPhysicsCategoryCamera;
    _baelog.physicsBody.contactTestBitMask = VMPhysicsCategoryTerrain;
    _baelog.physicsBody.restitution = 0.0;
    _baelog.physicsBody.friction = 1.0;
    _baelog.physicsBody.allowsRotation = NO;
    _baelog.physicsBody.angularVelocity = 0;
    
    CGSize knightPB = CGSizeMake(_knight.size.width - 25, _knight.size.height - 8);
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
    
    _level.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:collisionPath];
    _level.physicsBody.dynamic = NO;
    _level.physicsBody.categoryBitMask = VMPhysicsCategoryTerrain;
    _level.physicsBody.collisionBitMask = VMPhysicsCategoryBaelog;
    _level.physicsBody.contactTestBitMask = VMPhysicsCategoryBaelog;
    _level.physicsBody.restitution = 0.0;
    _level.physicsBody.friction = 1.0;
    [_level attachDebugFrameFromPath:collisionPath];
    CGPathRelease(collisionPath);
    
    [_bgLayer addChild:_level];
    
    SKSpriteNode *levelContinued = [SKSpriteNode spriteNodeWithImageNamed:@"level1-0-1.png"];
    levelContinued.name = @"bg";
    levelContinued.anchorPoint = CGPointZero;
    levelContinued.position = CGPointMake(_level.size.width, 0);
    
    collisionData = collisionDataDictionary[@"path_1"];
    
    NSMutableArray *terrainObjects = [[NSMutableArray alloc] init];
    for (NSArray *objects in collisionData) {
        collisionPath = CGPathCreateMutable();
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
        CGPathCloseSubpath(collisionPath);
        [terrainObjects addObject:[SKPhysicsBody bodyWithEdgeLoopFromPath:collisionPath]];
        [levelContinued attachDebugFrameFromPath:collisionPath];
        CGPathRelease(collisionPath);
    }
    
    
    
    levelContinued.physicsBody = [SKPhysicsBody bodyWithBodies:terrainObjects];
    levelContinued.physicsBody.dynamic = NO;
    levelContinued.physicsBody.categoryBitMask = VMPhysicsCategoryTerrain;
    levelContinued.physicsBody.collisionBitMask = VMPhysicsCategoryBaelog;
    levelContinued.physicsBody.contactTestBitMask = VMPhysicsCategoryBaelog;
    levelContinued.physicsBody.restitution = 0.0;
    
    
    
    [_bgLayer addChild:levelContinued];
}

-(void)initCameraFrame
{
    CGSize frame = CGSizeMake(self.size.width - 256, self.size.height - 256);
    CGRect rect = CGRectMake(self.size.width/2, self.size.height/2, frame.width, frame.height);
    _cameraFrame = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor] size:frame];
    /*CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, -frame.width/2, 0);
    CGPathAddLineToPoint(path, nil, 0, frame.height/2);
    CGPathAddLineToPoint(path, nil, frame.width/2, 0);
    CGPathAddLineToPoint(path, nil, 0, -frame.height/2);
    CGPathCloseSubpath(path);*/
    
    //_cameraFrame.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:path];
    _cameraFrame.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:rect];
    _cameraFrame.physicsBody.dynamic = NO;
    _cameraFrame.physicsBody.categoryBitMask = VMPhysicsCategoryCamera;
    _cameraFrame.physicsBody.collisionBitMask = VMPhysicsCategoryBaelog;
    _cameraFrame.physicsBody.contactTestBitMask = VMPhysicsCategoryBorderUp | VMPhysicsCategoryBorderDown | VMPhysicsCategoryBorderLeft | VMPhysicsCategoryBorderRight;
    _cameraFrame.anchorPoint = CGPointMake(0.5, 0.5);
    _cameraFrame.position = CGPointMake(self.size.width/2, self.size.height/2);
    [_cameraFrame attachDebugRectWithSize:frame];
    [_playerLayer addChild:_cameraFrame];
    
    //CGPathRelease(path);
    
    /*CGSize border = CGSizeMake(self.size.width, 1);
    
    //path = CGPathCreateMutable();
    //CGPathMoveToPoint(path, nil, -border.width/2, 0);
    //CGPathAddLineToPoint(path, nil, -border.width/2, 0);
    
    SKSpriteNode *borderUp = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor] size:border];
    borderUp.anchorPoint = CGPointZero;
    borderUp.position = CGPointMake(0, self.size.height-1);
    borderUp.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-borderUp.size.width/2, borderUp.size.height) toPoint:CGPointMake(borderUp.size.width/2, borderUp.size.height)];
    borderUp.physicsBody.categoryBitMask = VMPhysicsCategoryBorderUp;
    borderUp.physicsBody.contactTestBitMask = VMPhysicsCategoryCamera;
    borderUp.physicsBody.dynamic = NO;
    //[borderUp attachDebugFrameFromPath:path];
    
    SKSpriteNode *borderDown = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor] size:border];
    borderDown.anchorPoint = CGPointZero;
    borderDown.position = CGPointMake(0, 0);
    borderDown.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:border];
    borderDown.physicsBody.categoryBitMask = VMPhysicsCategoryBorderDown;
    borderDown.physicsBody.contactTestBitMask = VMPhysicsCategoryCamera;
    borderDown.physicsBody.dynamic = NO;
    [borderDown attachDebugRectWithSize:border];
    
    border = CGSizeMake(6, self.size.height);
    SKSpriteNode *borderLeft = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor] size:border];
    borderLeft.anchorPoint = CGPointZero;
    borderLeft.position = CGPointMake(0, 0);
    borderLeft.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:border];
    borderLeft.physicsBody.categoryBitMask = VMPhysicsCategoryBorderLeft;
    borderLeft.physicsBody.contactTestBitMask = VMPhysicsCategoryCamera;
    borderLeft.physicsBody.dynamic = NO;
    [borderLeft attachDebugRectWithSize:border];
    
    SKSpriteNode *borderRight = [[SKSpriteNode alloc] initWithColor:[SKColor greenColor] size:border];
    borderRight.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:border];
    borderRight.physicsBody.categoryBitMask = VMPhysicsCategoryBorderRight;
    borderRight.physicsBody.contactTestBitMask = VMPhysicsCategoryCamera;
    borderRight.physicsBody.dynamic = NO;
    //borderRight.anchorPoint = CGPointZero;
    borderRight.position = CGPointMake(self.size.width-10, self.size.height/2);
    [borderRight attachDebugRectWithSize:border];
    
    [_playerLayer addChild:borderUp];
    [_playerLayer addChild:borderDown];
    [_playerLayer addChild:borderLeft];
    [_playerLayer addChild:borderRight];
    */
    
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

-(void)idleBaelog
{
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
}

-(void)fallBaelog
{
    if (_midAir) {
        if (_baelog.physicsBody.velocity.dy < 0) {
            if (![_baelog actionForKey:@"fallAnimation"] && ![_baelog actionForKey:@"fallLeftAnimation"]) {
                [_baelog removeAllActions];
                if (_baelog.rightDirection) {
                    [_baelog runAction:[SKAction repeatActionForever:_fallAnimation] withKey:@"fallAnimation"];
                }
                else
                {
                    [_baelog runAction:[SKAction repeatActionForever:_fallLeftAnimation] withKey:@"fallLeftAnimation"];
                }
            }
        }
    }
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
            _velocity = CGPointMake(BAELOG_MOVEMENT_SPEED, 0);
            _baelog.rightDirection = YES;
            [self moveBaelogRight];
            continue;
        }
        if ([node.name isEqualToString:@"left"]) {
            //self moveSprite:_baelog velocity:(CGPoint)
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
        //go through nodes, get the zPosition if you want
        //int nodePos = node.zPosition;
        
        //or check the node against your nodes
        if ([node.name isEqualToString:@"right"]) {
            [self stopBaelog];
        } else if ([node.name isEqualToString:@"left"]) {
            [self stopBaelog];
        }
        else {
            //_right.colorBlendFactor = 0;
            
            
        }
    }
    
}

#pragma mark Movement

- (void)moveSprite:(SKNode *)sprite
          velocity:(CGPoint)velocity
{
    
    //CGPoint normalized = CGPointNormalize(velocity);
    
    // 1
    
    CGPoint amountToMove = CGPointMultiplyScalar(velocity, _dt);
    //NSLog(@"Amount to move: %@", NSStringFromCGPoint(amountToMove));
    
    // 2
    sprite.position = CGPointAdd(sprite.position, amountToMove);
    
    
    
    //testing
    /*
    CGFloat rate = .05;
    CGVector relativeVelocity = CGVectorMake(200-sprite.physicsBody.velocity.dx, 200-sprite.physicsBody.velocity.dy);
    sprite.physicsBody.velocity=CGVectorMake(sprite.physicsBody.velocity.dx+relativeVelocity.dx*rate, sprite.physicsBody.velocity.dy+relativeVelocity.dy*rate);
     */
    
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
        //[_baelog removeActionForKey:@"idleLeftAnimation"];
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
        //[_baelog removeActionForKey:@"idleLeftAnimation"];
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

-(void)makeCamerVector
{
    //NSLog(@"baelog: %f, %f", _baelog.position.x, _baelog.position.y);
    CGPoint relativePoint = [_playerLayer convertPoint:_baelog.position toNode:self];
    _camera = CGPointMake(relativePoint.x - self.size.width/2, relativePoint.y - self.size.height/2);
}

-(void)moveCamera
{
    if (!CGPointEqualToPoint(_camera, CGPointZero)) {
        //__block CGPoint velocityVector = CGPointMultiplyScalar(_camera, -1);
        [self runAction:[SKAction sequence:@[[SKAction waitForDuration:0.2],
                                             [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
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
            [self moveSprite:_bgLayer velocity:velocityVector];
        }]]]];
    }
}

-(void)cameraMovedTowards:(NSString *)direction
{
    if (_baelog.physicsBody.resting) {
        if ([direction isEqualToString:@"right"]) {
            //_baelog.position = CGPointSubtract(_baelog.position, CGPointMake(10, 0));
            //[_baelog runAction:[SKAction moveByX:-5 y:0 duration:0.1]];
            [self moveSprite:_baelog velocity:CGPointMake(-BAELOG_MOVEMENT_SPEED, 0)];
        }
        else if ([direction isEqualToString:@"left"]) {
            //_baelog.position = CGPointAdd(_baelog.position, CGPointMake(10, 0));
            //[_baelog runAction:[SKAction moveByX:5 y:0 duration:0.1]];
            [self moveSprite:_baelog velocity:CGPointMake(BAELOG_MOVEMENT_SPEED, 0)];
        }
        else if ([direction isEqualToString:@"up"]) {
            [self moveSprite:_baelog velocity:CGPointMake(0, -BAELOG_MOVEMENT_SPEED)];
        }
        else if ([direction isEqualToString:@"down"]) {
            [self moveSprite:_baelog velocity:CGPointMake(0, BAELOG_MOVEMENT_SPEED)];
        }
    }
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

-(void)determineMidAir
{
    if ((_baelog.physicsBody.velocity.dy >= 0.001) || (_baelog.physicsBody.velocity.dy <= -0.001)) {
        //NSLog(@"midair velocity = %f", _baelog.physicsBody.velocity.dy);
        _midAir = YES;
    }
    else
    {
        //NSLog(@"Not midair velocity = %f", _baelog.physicsBody.velocity.dy);
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
        }
        else
        {
            [_baelog runAction:[SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"frameLeft"] timePerFrame:0]];
        }
    }
    if (collision == (VMPhysicsCategoryCamera | VMPhysicsCategoryBorderUp)) {
        NSLog(@"up");
    }
    if (collision == (VMPhysicsCategoryCamera | VMPhysicsCategoryBorderDown)) {
        NSLog(@"down");
    }
    if (collision == (VMPhysicsCategoryCamera | VMPhysicsCategoryBorderLeft)) {
        NSLog(@"left");
    }
    if (collision == (VMPhysicsCategoryCamera | VMPhysicsCategoryBorderRight)) {
        NSLog(@"right");
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
