//
//  Knight.m
//  Viking Madness
//
//  Created by Dion Kak on 29/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import "Knight.h"
#import "SKTAudio.h"

static const CGFloat KNIGHT_WALK_MOVEMENT_SPEED = 32;
static const CGFloat KNIGHT_CHASE_MOVEMENT_SPEED = KNIGHT_WALK_MOVEMENT_SPEED * 2;
static const float KNIGHT_MAX_HEALTH = 100;

@implementation Knight
{
    NSArray *_walkLeft;
    NSArray *_walkRight;
    NSArray *_slashLeft;
    NSArray *_slashRight;
    
    BOOL _rightDirection;
    BOOL _stopPatrol;
    BOOL _combat;
    
    
    CGPoint _velocity;
    CGPoint _startPos;
    
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    
    CGFloat _lastPosition;
    CGFloat _dx;
    
    SKAction *_walkRightAnimation;
    SKAction *_walkLeftAnimation;
    SKAction *_chaseRightAnimation;
    SKAction *_chaseLeftAnimation;
    SKAction *_slashRightAnimation;
    SKAction *_slashLeftAnimation;
    
    CGFloat _endPosition;
}

-(instancetype)initWithPosition:(CGPoint)position
{
    if (self = [super initWithPosition:CGPointMake(position.x + 25, position.y)]) {
        self.name = @"knight";
        _startPos = position;
        _rightDirection = NO;
        _stopPatrol = NO;
        _velocity = CGPointZero;
        self.health = KNIGHT_MAX_HEALTH;
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
    if (self.health <= 0) {
        [self removeFromParent];
    }
    _hostileDistance = CGPointDistance(self.position, _hostilePosition);
    [self checkToEngageCombat];
    [self followHostile];
    [self moveSprite:self velocity:_velocity];
}

-(void)didEvaluateActions
{
    if ([self reachedEndOfPatrol]) {
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
    _chaseRightAnimation = [SKAction animateWithTextures:[self animationTexturesWithKey:@"walkRight"] timePerFrame:0.1];
    _chaseLeftAnimation = [SKAction animateWithTextures:[self animationTexturesWithKey:@"walkLeft"] timePerFrame:0.1];
    _slashRightAnimation = [SKAction animateWithTextures:[self animationTexturesWithKey:@"slashRight"] timePerFrame:0.1];
    _slashLeftAnimation = [SKAction animateWithTextures:[self animationTexturesWithKey:@"slashLeft"] timePerFrame:0.1];
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
    if (_combat) {
        return NO;
    }
    if (self.position.x < _startPos.x) {
        _rightDirection = YES;
        return YES;
    }
    if (self.position.x > _endPosition - self.size.width/2) {
        _rightDirection = NO;
        return YES;
    }
    return NO;
}

-(void)changeDirectionOfPatrol
{
    if (_stopPatrol) {
        return;
    }
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
}


#pragma mark Combat

-(void)checkToEngageCombat
{
    //NSLog(@"%f",_hostileDistance);
    if (_hostileDistance < 100) {
        //NSLog(@"HOSTILE DETECTED");
        _stopPatrol = YES;
        _combat = YES;
        if (![self actionForKey:@"chaseRight"] &&
            ![self actionForKey:@"chaseLeft"] &&
            ![self actionForKey:@"slashRight"] &&
            ![self actionForKey:@"slashLeft"])
        {
            [self removeAllActions];
            if (self.position.x < _hostilePosition.x) {
                _rightDirection = YES;
                _velocity = CGPointMake(KNIGHT_CHASE_MOVEMENT_SPEED, 0);
                [self runAction:[SKAction repeatActionForever:_chaseRightAnimation] withKey:@"chaseRight"];
            }
            else
            {
                _rightDirection = NO;
                _velocity = CGPointMake(-KNIGHT_CHASE_MOVEMENT_SPEED, 0);
                [self runAction:[SKAction repeatActionForever:_chaseLeftAnimation] withKey:@"chaseLeft"];
            }
        }
    }
}

-(void)takeDamage:(float)damage
{
    //NSLog(@"id%@: HP:%f, damage:%f", self.description, self.health, damage);
    self.health -= damage;
    if (self.health <= 0) {
        [self removeFromParent];
    }
}

-(void)followHostile
{
    if (!_combat) {
        return;
    }
    if (_enemy.dead) {
        _velocity = CGPointZero;
        [self removeAllActions];
        self.texture = [SKTexture textureWithImageNamed:@"Knight_Walk_0"];
        return;
    }
    if (_hostileDistance > self.size.width - 20) {
        if (![self actionForKey:@"chaseRight"] &&
            ![self actionForKey:@"chaseLeft"] &&
            ![self actionForKey:@"slashRight"] &&
            ![self actionForKey:@"slashLeft"]) {
            if (_rightDirection) {
                _velocity = CGPointMake(KNIGHT_CHASE_MOVEMENT_SPEED, 0);
                [self runAction:[SKAction repeatActionForever:_chaseRightAnimation] withKey:@"chaseRight"];
            }
            else
            {
                _velocity = CGPointMake(-KNIGHT_CHASE_MOVEMENT_SPEED, 0);
                [self runAction:[SKAction repeatActionForever:_chaseLeftAnimation] withKey:@"chaseLeft"];
            }
        }
    }
    else
    {
        [self attack];
    }
}

-(void)attack
{
    if ([self actionForKey:@"slashRight"] ||
        [self actionForKey:@"slashLeft"] ||
        [self actionForKey:@"damage"])
    {
        return;
    }
    [self removeActionForKey:@"chaseLeft"];
    [self removeActionForKey:@"chaseRight"];
    _velocity = CGPointZero;
    
    if (_rightDirection) {
        if (![self actionForKey:@"slashRight"]) {
            [self runAction:_slashRightAnimation withKey:@"slashRight"];
        }
    }
    else
    {
        if (![self actionForKey:@"slashLeft"]) {
            [self runAction:_slashLeftAnimation withKey:@"slashLeft"];
        }
    }
    [self dealDamage:_rightDirection];
}

-(void)dealDamage:(BOOL)toRightDirection
{
    if (([self actionForKey:@"slashRight"] ||
        [self actionForKey:@"slashLeft"]) &&
        ![self actionForKey:@"damage"])
    {
        CGVector pulse;
        SKAction *damage;
        if (toRightDirection)
        {
            pulse = CGVectorMake(2, 6.3);
            damage = [SKAction customActionWithDuration:1.6 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                if (elapsedTime >= 0.3) {
                    if (_hostileDistance < self.size.width - 20) {
                        [_enemy.physicsBody applyImpulse:pulse atPoint:CGPointMake(0, 0)];
                        [_enemy takeDamage:10];
                        [[SKTAudio sharedInstance] playSoundEffect:@"knightSword.wav"];
                        [self removeActionForKey:@"damage"];
                    }
                }
            }];
        }
        else
        {
            pulse = CGVectorMake(-2, 6.3);
            damage = [SKAction customActionWithDuration:1.6 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                if (elapsedTime >= 0.3) {
                    if (_hostileDistance < 32) {
                        [_enemy.physicsBody applyImpulse:pulse atPoint:CGPointMake(0, 0)];
                        [_enemy takeDamage:10];
                        [[SKTAudio sharedInstance] playSoundEffect:@"knightSword.wav"];
                        [self removeActionForKey:@"damage"];
                    }
                }
            }];
        }
        
        [self runAction:damage withKey:@"damage"];
    }
}


@end
