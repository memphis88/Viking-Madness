//
//  Knight.m
//  Viking Madness
//
//  Created by Dion Kak on 29/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import "Knight.h"

static const CGFloat KNIGHT_WALK_MOVEMENT_SPEED = 32;
static const CGFloat KNIGHT_CHASE_MOVEMENT_SPEED = KNIGHT_WALK_MOVEMENT_SPEED * 2;

@implementation Knight
{
    NSArray *_walkLeft;
    NSArray *_walkRight;
    NSArray *_slashLeft;
    NSArray *_slashRight;
    
    BOOL _rightDirection;
    BOOL _changing;
    
    CGPoint _velocity;
    CGPoint _startPos;
    
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    
    CGFloat _lastPosition;
    CGFloat _dx;
    
    SKAction *_walkRightAnimation;
    SKAction *_walkLeftAnimation;
    
    CGFloat _endPosition;
}

-(instancetype)initWithPosition:(CGPoint)position
{
    if (self = [super initWithPosition:CGPointMake(position.x + 25, position.y)]) {
        self.name = @"knight";
        _startPos = position;
        _rightDirection = NO;
        _changing = NO;
        _velocity = CGPointZero;
        [self initActions];
    }
    return self;
}

-(void)setPatrolWidth:(NSString *)patrolWidth
{
    _patrolWidth = patrolWidth;
    _endPosition = _startPos.x + [_patrolWidth floatValue];
}

-(void)update:(CFTimeInterval)delta
{
    _dt = delta;
    if (_lastPosition) {
        _dx = self.position.x - _lastPosition;
    }
    else
    {
        _dx = 0;
    }
    _lastPosition = self.position.x;
    
    //NSLog(@"dt:%f",_dt);
    [self moveSprite:self velocity:_velocity];
}

-(void)didEvaluateActions
{
    if ([self reachedEndOfPatrol] && !_changing) {
        [self changeDirectionOfPatrol];
    }
}

+(SKTexture *)generateTexture
{
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKSpriteNode *knight = [SKSpriteNode spriteNodeWithImageNamed:@"Knight_Walk_0"];
        SKView *textureView = [SKView new];
        texture = [textureView textureFromNode:knight];
        texture.filteringMode = SKTextureFilteringNearest;
    });
    return texture;
}

-(NSArray *)animationTexturesWithKey:(NSString *)key
{
    NSArray *textures;
    if ([key isEqualToString:@"walkLeft"]) {
        textures = [self walkLeftAnimation];
    } else if ([key isEqualToString:@"walkRight"]) {
        textures = [self walkRightAnimation];
    }
    else if ([key isEqualToString:@"slashLeft"]) {
        textures = [self slashLeftAnimation];
    }
    else if ([key isEqualToString:@"slashRight"]) {
        textures = [self slashRightAnimation];
    }
    return textures;
}

#pragma mark Initializers

-(void)initActions
{
    _walkLeftAnimation = [SKAction animateWithTextures:[self animationTexturesWithKey:@"walkLeft"] timePerFrame:0.2];
    _walkRightAnimation = [SKAction animateWithTextures:[self animationTexturesWithKey:@"walkRight"] timePerFrame:0.2];
}

#pragma mark Animation

-(NSArray *)walkLeftAnimation
{
    if (_walkLeft) {
        return _walkLeft;
    }
    NSMutableArray *textures = [[NSMutableArray alloc] initWithCapacity:20];
    for (int i = 0; i < 9; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Knight_Walk_%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _walkLeft = [NSArray arrayWithArray:textures];
    return _walkLeft;
}

-(NSArray *)walkRightAnimation
{
    if (_walkRight) {
        return _walkRight;
    }
    NSMutableArray *textures = [[NSMutableArray alloc] initWithCapacity:20];
    for (int i = 9; i < 18; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Knight_Walk_%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _walkRight = [NSArray arrayWithArray:textures];
    return _walkRight;
}

-(NSArray *)slashLeftAnimation
{
    if (_slashLeft) {
        return _slashLeft;
    }
    NSMutableArray *textures = [[NSMutableArray alloc] initWithCapacity:20];
    NSString *textureName;
    for (int i = 1; i < 7; i++) {
        textureName = [NSString stringWithFormat:@"Knight_SSlash_%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _slashLeft = [NSArray arrayWithArray:textures];
    return _slashLeft;
}

-(NSArray *)slashRightAnimation
{
    if (_slashRight) {
        return _slashRight;
    }
    NSMutableArray *textures = [[NSMutableArray alloc] initWithCapacity:20];
    for (int i = 7; i < 13; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Knight_SSlash_%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _slashRight = [NSArray arrayWithArray:textures];
    return _slashRight;
}

#pragma mark Behavior

-(void)startPatrol
{
    _velocity = CGPointMake(KNIGHT_WALK_MOVEMENT_SPEED, 0);
    [self runAction:[SKAction repeatActionForever:_walkRightAnimation] withKey:@"walkRight"];
}

#pragma mark Movement

- (void)moveSprite:(SKNode *)sprite
          velocity:(CGPoint)velocity
{
    CGPoint amountToMove = CGPointMultiplyScalar(velocity, _dt);
    sprite.position = CGPointAdd(sprite.position, amountToMove);
    
}

-(BOOL)reachedEndOfPatrol
{
    if (self.position.x < _startPos.x) {
        //NSLog(@"reached left");
        return YES;
    }
    if (self.position.x > _endPosition - self.size.width/2) {
        //NSLog(@"reached right");
        return YES;
    }
    return NO;
}

-(void)changeDirectionOfPatrol
{
    _changing = YES;
    _rightDirection = !_rightDirection;
    if (_rightDirection) {
        if (![self actionForKey:@"walkRight"]) {
            [self removeAllActions];
            _velocity = CGPointMake(KNIGHT_WALK_MOVEMENT_SPEED, 0);
            [self runAction:[SKAction repeatActionForever:_walkRightAnimation] withKey:@"walkRight"];
        }
    }
    else
    {
        if (![self actionForKey:@"walkLeft"]) {
            [self removeAllActions];
            _velocity = CGPointMake(-KNIGHT_WALK_MOVEMENT_SPEED, 0);
            [self runAction:[SKAction repeatActionForever:_walkLeftAnimation] withKey:@"walkLeft"];
        }
    }
    _changing = NO;
}


#pragma mark Combat

@end
