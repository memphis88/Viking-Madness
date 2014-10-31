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

@implementation FirstLevel
{
    SKSpriteNode *_background;
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
    SKAction *_idleAnimation;
    SKAction *_walkLeftAnimation;
    SKAction *_idleLeftAnimation;
    
    BOOL _idle;
    CGPoint _velocity;
}

#pragma mark Overriden methods

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        _bgLayer = [SKNode node];
        [self addChild:_bgLayer];
        [self initBackground];
        _playerLayer = [SKNode node];
        [self addChild:_playerLayer];
        [self initEntities];
        _userInterface = [SKNode node];
        [self initUserInterface];
        [self addChild:_userInterface];
        [self initActions];
    }
    _velocity = CGPointZero;
    _idleTime = 0;
    _idle = NO;
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
}

#pragma mark Initializers

-(void)initBackground
{
    
    _background = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:self.size];
    _background.anchorPoint = CGPointZero;
    _background.position = CGPointMake(0, 0);
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    [_bgLayer addChild:_background];
}

-(void)initEntities
{
    _baelog = [[Baelog alloc] initWithPosition:CGPointMake(self.size.width/2, 70)];
    _baelog.rightDirection = YES;
    _knight = [[Knight alloc] initWithPosition:CGPointMake(self.size.width/2 + 250, 70)];
    
    _baelog.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_baelog.size];
    _knight.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_knight.size];
    
    /*
     *debuging frames
     */
    
    [_baelog attachDebugRectWithSize:_baelog.size];
    [_knight attachDebugRectWithSize:_knight.size];
    
    _baelog.yScale = 3.0;
    _baelog.xScale = 3.0;
    _knight.yScale = 2.0;
    _knight.xScale = 2.0;
    
    
    
    
    [_playerLayer addChild:_baelog];
    [_playerLayer addChild:_knight];
}

-(void)initTerrain
{
    
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
    
    //[_userInterface runAction:[SKAction scaleTo:0.7 duration:0]];
    
}

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
            break;
        }
        if ([node.name isEqualToString:@"left"]) {
            //self moveSprite:_baelog velocity:(CGPoint)
            _right.color = [SKColor yellowColor];
            _right.colorBlendFactor = 1.0;
            _velocity = CGPointMake(-self.size.width/3, 0);
            _baelog.rightDirection = NO;
            [self moveBaelogLeft];
            break;
        }
        if ([node.name isEqualToString:@"jump"]) {
            [_baelog.physicsBody applyImpulse:CGVectorMake(0, 30)];
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
    [_baelog removeActionForKey:@"walkRightAnimation"];
    [_baelog removeActionForKey:@"walkLeftAnimation"];
    if (_baelog.rightDirection) {
        [_baelog runAction:[SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"frame"] timePerFrame:0]];
    }
    else
    {
        [_baelog runAction:[SKAction animateWithTextures:[_baelog animationTexturesWithKey:@"frameLeft"] timePerFrame:0]];
    }
}

@end
