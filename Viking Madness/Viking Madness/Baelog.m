//
//  Baelog.m
//  Viking Madness
//
//  Created by Dionysios Kakouris on 22/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import "Baelog.h"
#import "Knight.h"
#import "SKTAudio.h"

static const float BAELOG_MAX_HEALTH = 100;


@implementation Baelog
{
    NSArray *_walk;
    NSArray *_jump;
    NSArray *_climb;
    NSArray *_idle;
    NSArray *_fall;
    NSArray *_swordSwing;
    NSArray *_pushObject;
    NSArray *_struck;
    NSArray *_idle2;
    NSArray *_idle3;
    NSArray *_directPunch;
    NSArray *_pushUp;
    NSArray *_hang;
    NSArray *_singleFrame;
    NSArray *_voidFallFrame;
    NSArray *_death;
    
    NSArray *_walkL;
    NSArray *_jumpL;
    NSArray *_climbL;
    NSArray *_idleL;
    NSArray *_fallL;
    NSArray *_swordSwingL;
    NSArray *_pushObjectL;
    NSArray *_struckL;
    NSArray *_idle2L;
    NSArray *_idle3L;
    NSArray *_directPunchL;
    NSArray *_pushUpL;
    NSArray *_hangL;
    NSArray *_singleFrameL;
    NSArray *_voidFallFrameL;
    NSArray *_deathL;
    
    NSTimeInterval _dt;
    NSTimeInterval _tick;
    NSTimeInterval _deathTimer;
    
    BOOL _fallDeath;
    
}

-(instancetype)initWithPosition:(CGPoint)position
{
    if (self = [super initWithPosition:position]) {
        self.name = @"baelog";
        self.health = BAELOG_MAX_HEALTH;
        self.energy = 100;
        self.dead = NO;
        _deathTimer = 0;
        _lives = 3;
    }
    return self;
}

+(SKTexture *)generateTexture
{
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKSpriteNode *baelog = [SKSpriteNode spriteNodeWithImageNamed:@"Baelog-2-0"];
        SKView *textureView = [SKView new];
        texture = [textureView textureFromNode:baelog];
        texture.filteringMode = SKTextureFilteringNearest;
    });
    return texture;
}

-(void)update:(CFTimeInterval)delta
{
    _dt = delta;
    [self regenerateEnergy];
    [self death];
}

-(NSArray *)animationTexturesWithKey:(NSString *)key
{
    if ([key isEqualToString:@"walk"]) {
        return [self walkAnimation];
    } else if ([key isEqualToString:@"climb"]) {
        return [self climbAnimation];
    } else if ([key isEqualToString:@"jump"]) {
        return [self jumpAnimation];
    } else if ([key isEqualToString:@"idle"]) {
        return [self idleAnimation];
    } else if ([key isEqualToString:@"fall"]) {
        return [self fallAnimation];
    } else if ([key isEqualToString:@"swordSwing"]) {
        return [self swordSwingAnimation];
    } else if ([key isEqualToString:@"pushObject"]) {
        return [self pushObjectAnimation];
    } else if ([key isEqualToString:@"struck"]) {
        return [self struckAnimation];
    } else if ([key isEqualToString:@"idle2"]) {
        return [self idle2Animation];
    } else if ([key isEqualToString:@"idle3"]) {
        return [self idle3Animation];
    } else if ([key isEqualToString:@"directPunch"]) {
        return [self directPunchAnimation];
    } else if ([key isEqualToString:@"pushUp"]) {
        return [self pushUpAnimation];
    } else if ([key isEqualToString:@"hang"]) {
        return [self hangAnimation];
    } else if ([key isEqualToString:@"frame"]) {
        return [self singleFrame];
    } else if ([key isEqualToString:@"voidFall"]) {
        return [self voidFallFrame];
    } else if ([key isEqualToString:@"death"]) {
        return [self deathAnimation];
    } else if ([key isEqualToString:@"walkLeft"]) {
        return [self walkAnimationLeft];
    } else if ([key isEqualToString:@"climbLeft"]) {
        return [self climbAnimationLeft];
    } else if ([key isEqualToString:@"jumpLeft"]) {
        return [self jumpAnimationLeft];
    } else if ([key isEqualToString:@"idleLeft"]) {
        return [self idleAnimationLeft];
    } else if ([key isEqualToString:@"fallLeft"]) {
        return [self fallAnimationLeft];
    } else if ([key isEqualToString:@"swordSwingLeft"]) {
        return [self swordSwingAnimationLeft];
    } else if ([key isEqualToString:@"pushObjectLeft"]) {
        return [self pushObjectAnimationLeft];
    } else if ([key isEqualToString:@"struckLeft"]) {
        return [self struckAnimationLeft];
    } else if ([key isEqualToString:@"idle2Left"]) {
        return [self idle2AnimationLeft];
    } else if ([key isEqualToString:@"idle3Left"]) {
        return [self idle3AnimationLeft];
    } else if ([key isEqualToString:@"directPunchLeft"]) {
        return [self directPunchAnimationLeft];
    } else if ([key isEqualToString:@"pushUpLeft"]) {
        return [self pushUpAnimationLeft];
    } else if ([key isEqualToString:@"hangLeft"]) {
        return [self hangAnimationLeft];
    } else if ([key isEqualToString:@"frameLeft"]) {
        return [self singleFrameLeft];
    } else if ([key isEqualToString:@"voidFallLeft"]) {
        return [self voidFallFrameLeft];
    } else if ([key isEqualToString:@"deathLeft"]) {
        return [self deathAnimationLeft];
    }
    return nil;
}

#pragma mark -
#pragma mark Right Movement

-(NSArray *)walkAnimation
{
    if (_walk) {
        return _walk;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=0; i < 8; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-0-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _walk = [NSArray arrayWithArray:textures];
    return _walk;
}

-(NSArray *)climbAnimation
{
    if (_climb) {
        return _climb;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=0; i < 6; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-1-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _climb = [NSArray arrayWithArray:textures];
    return _climb;
}

-(NSArray *)jumpAnimation
{
    if (_jump) {
        return _jump;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    NSString *textureName = @"Baelog11-1";
    SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
    [textures addObject:texture];
    textureName = @"Baelog11-2";
    texture = [SKTexture textureWithImageNamed:textureName];
    [textures addObject:texture];
    _jump = [NSArray arrayWithArray:textures];
    return _jump;
}

-(NSArray *)idleAnimation
{
    if (_idle) {
        return _idle;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=0; i < 2; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-2-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    for (int i=1; i >=0 ; i--) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-2-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _idle = [NSArray arrayWithArray:textures];
    return _idle;
}

-(NSArray *)fallAnimation
{
    if (_fall) {
        return _fall;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=0; i < 2; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-3-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _fall = [NSArray arrayWithArray:textures];
    return _fall;
}

-(NSArray *)swordSwingAnimation
{
    if (_swordSwing) {
        return _swordSwing;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=0; i < 6; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-4-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _swordSwing = [NSArray arrayWithArray:textures];
    return _swordSwing;
}

-(NSArray *)pushObjectAnimation
{
    if (_pushObject) {
        return _pushObject;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=0; i < 4; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-5-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _pushObject = [NSArray arrayWithArray:textures];
    return _pushObject;
}

-(NSArray *)struckAnimation
{
    if (_struck) {
        return _struck;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=0; i < 2; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-6-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _struck = [NSArray arrayWithArray:textures];
    return _struck;
}

-(NSArray *)idle2Animation
{
    if (_idle2) {
        return _idle2;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=0; i < 3; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-7-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    for (int i=2; i >= 0; i--) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-7-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _idle2 = [NSArray arrayWithArray:textures];
    return _idle2;
}

-(NSArray *)idle3Animation
{
    if (_idle3) {
        return _idle3;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=0; i < 4; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-8-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    for (int i=3; i >= 0; i--) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-8-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _idle3 = [NSArray arrayWithArray:textures];
    return _idle3;
}

-(NSArray *)directPunchAnimation
{
    if (_directPunch) {
        return _directPunch;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=0; i < 4; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog-9-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _directPunch = [NSArray arrayWithArray:textures];
    return _directPunch;
}

-(NSArray *)pushUpAnimation
{
    if (_pushUp) {
        return _pushUp;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=0; i < 2; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog10-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _pushUp = [NSArray arrayWithArray:textures];
    return _pushUp;
}

-(NSArray *)hangAnimation
{
    if (_hang) {
        return _hang;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=0; i < 8; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog11-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _hang = [NSArray arrayWithArray:textures];
    return _hang;
}

-(NSArray *)singleFrame
{
    if (_singleFrame) {
        return _singleFrame;
    }
    _singleFrame = [NSArray arrayWithObject:[SKTexture textureWithImageNamed:@"Baelog-2-0"]];
    return _singleFrame;
}

-(NSArray *)voidFallFrame
{
    if (_voidFallFrame) {
        return _voidFallFrame;
    }
    _voidFallFrame = [NSArray arrayWithObject:[SKTexture textureWithImageNamed:@"Baelog15-0"]];
    return _voidFallFrame;
}

-(NSArray *)deathAnimation
{
    if (_death) {
        return _death;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i = 0; i < 4; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Baelog16-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _death = [NSArray arrayWithArray:textures];
    return _death;
}

#pragma mark Left Movement

-(NSArray *)walkAnimationLeft
{
    if (_walkL) {
        return _walkL;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=7; i >= 0; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-0-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _walkL = [NSArray arrayWithArray:textures];
    return _walkL;
}

-(NSArray *)climbAnimationLeft
{
    if (_climbL) {
        return _climbL;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=7; i >= 0; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-1-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _climbL = [NSArray arrayWithArray:textures];
    return _climbL;
}

-(NSArray *)jumpAnimationLeft
{
    if (_jumpL) {
        return _jumpL;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    NSString *textureName = @"LBaelog11-6";
    SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
    [textures addObject:texture];
    textureName = @"LBaelog11-5";
    texture = [SKTexture textureWithImageNamed:textureName];
    [textures addObject:texture];
    _jumpL = [NSArray arrayWithArray:textures];
    return _jumpL;
}

-(NSArray *)idleAnimationLeft
{
    if (_idleL) {
        return _idleL;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=7; i >= 6; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-2-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    for (int i=6; i <= 7 ; i++) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-2-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _idleL = [NSArray arrayWithArray:textures];
    return _idleL;
}

-(NSArray *)fallAnimationLeft
{
    if (_fallL) {
        return _fallL;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=7; i >= 6; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-3-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _fallL = [NSArray arrayWithArray:textures];
    return _fallL;
}

-(NSArray *)swordSwingAnimationLeft
{
    if (_swordSwingL) {
        return _swordSwingL;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=7; i >= 2; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-4-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _swordSwingL = [NSArray arrayWithArray:textures];
    return _swordSwingL;
}

-(NSArray *)pushObjectAnimationLeft
{
    if (_pushObjectL) {
        return _pushObjectL;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=7; i >= 4; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-5-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _pushObjectL = [NSArray arrayWithArray:textures];
    return _pushObjectL;
}

-(NSArray *)struckAnimationLeft
{
    if (_struckL) {
        return _struckL;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=7; i >= 6; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-6-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _struckL = [NSArray arrayWithArray:textures];
    return _struckL;
}

-(NSArray *)idle2AnimationLeft
{
    if (_idle2L) {
        return _idle2L;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=7; i >= 5; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-7-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    for (int i=5; i <= 7; i++) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-7-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _idle2L = [NSArray arrayWithArray:textures];
    return _idle2L;
}

-(NSArray *)idle3AnimationLeft
{
    if (_idle3L) {
        return _idle3L;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=7; i >= 4; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-8-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    for (int i=4; i >= 7; i++) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-8-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _idle3L = [NSArray arrayWithArray:textures];
    return _idle3L;
}

-(NSArray *)directPunchAnimationLeft
{
    if (_directPunchL) {
        return _directPunchL;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=7; i >= 4; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog-9-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _directPunchL = [NSArray arrayWithArray:textures];
    return _directPunchL;
}

-(NSArray *)pushUpAnimationLeft
{
    if (_pushUpL) {
        return _pushUpL;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=7; i >= 6; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog10-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _pushUpL = [NSArray arrayWithArray:textures];
    return _pushUpL;
}

-(NSArray *)hangAnimationLeft
{
    if (_hangL) {
        return _hangL;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i=7; i >= 0; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog11-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _hangL = [NSArray arrayWithArray:textures];
    return _hangL;
}

-(NSArray *)singleFrameLeft
{
    if (_singleFrameL) {
        return _singleFrameL;
    }
    _singleFrameL = [NSArray arrayWithObject:[SKTexture textureWithImageNamed:@"LBaelog-2-7"]];
    return _singleFrameL;
}

-(NSArray *)voidFallFrameLeft
{
    if (_voidFallFrameL) {
        return _voidFallFrameL;
    }
    _voidFallFrameL = [NSArray arrayWithObject:[SKTexture textureWithImageNamed:@"LBaelog15-7"]];
    return _voidFallFrameL;
}

-(NSArray *)deathAnimationLeft
{
    if (_deathL) {
        return _deathL;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:8];
    for (int i = 7; i >= 4; i--) {
        NSString *textureName = [NSString stringWithFormat:@"LBaelog16-%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    _deathL = [NSArray arrayWithArray:textures];
    return _deathL;
}

#pragma mark -
#pragma mark Combat

-(void)takeDamage:(float)damage
{
    self.health -= damage;
    [self removeAllActions];
    if (_rightDirection) {
        [self runAction:[SKAction sequence:@[[SKAction animateWithTextures:[self animationTexturesWithKey:@"struck"] timePerFrame:0.1],
                                             [SKAction animateWithTextures:[self animationTexturesWithKey:@"frame"] timePerFrame:0]]] withKey:@"struck"];
    }
    else
    {
        [self runAction:[SKAction sequence:@[[SKAction animateWithTextures:[self animationTexturesWithKey:@"struckLeft"] timePerFrame:0.1],
                                             [SKAction animateWithTextures:[self animationTexturesWithKey:@"frameLeft"] timePerFrame:0]]] withKey:@"struckLeft"];
        
    }
}

-(void)dealDamage:(NSMutableArray *)entities attackType:(AttackType)attack
{
    for (Knight *knight in entities) {
        if (![knight parent]) {
            continue;
        }
        if (knight.hostileDistance < (self.size.width/2 + knight.size.width/2)) {
            if (([self actionForKey:@"swingLeft"] ||
                 [self actionForKey:@"swingRight"] ||
                 [self actionForKey:@"punchLeft"] ||
                 [self actionForKey:@"punchRight"]) &&
                ![self actionForKey:@"damage"])
            {
                
                SKAction *damage;
                if (_rightDirection)
                {
                    damage = [SKAction customActionWithDuration:0.6 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                        if (elapsedTime >= 0.3) {
                            if (knight.hostileDistance <= 32) {
                                CGVector pulse;
                                if (attack == Punch) {
                                    pulse = CGVectorMake(45, 0.3);
                                    [knight takeDamage:30];
                                    [[SKTAudio sharedInstance] playSoundEffect:@"punch.wav"];
                                }
                                else if (attack == Slash)
                                {
                                    if (_energy > 50) {
                                        _energy -= 50;
                                        pulse = CGVectorMake(10, 45);
                                        [knight takeDamage:50];
                                        [[SKTAudio sharedInstance] playSoundEffect:@"baelogSword.wav"];
                                    }
                                    else
                                    {
                                        return ;
                                    }
                                }
                                [knight.physicsBody applyImpulse:pulse atPoint:CGPointMake(0, 0)];
                                [self removeActionForKey:@"damage"];
                            }
                        }
                    }];
                }
                else
                {
                    
                    damage = [SKAction customActionWithDuration:0.6 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                        if (elapsedTime >= 0.3) {
                            CGVector pulse;
                            if (knight.hostileDistance < 32) {
                                
                                if (attack == Punch) {
                                    pulse = CGVectorMake(-45, 0.3);
                                    [knight takeDamage:30];
                                    [[SKTAudio sharedInstance] playSoundEffect:@"punch.wav"];
                                }
                                else if (attack == Slash)
                                {
                                    if (_energy > 50) {
                                        _energy -= 50;
                                        pulse = CGVectorMake(-10, 45);
                                        [knight takeDamage:50];
                                        [[SKTAudio sharedInstance] playSoundEffect:@"baelogSword.wav"];
                                    }
                                    else
                                    {
                                        return ;
                                    }
                                }
                                [knight.physicsBody applyImpulse:pulse atPoint:CGPointMake(0, 0)];
                                [self removeActionForKey:@"damage"];
                            }
                        }
                    }];
                }
                
                [self runAction:damage withKey:@"damage"];
            }
        }
        
    }
}

-(void)regenerateEnergy
{
    if (self.energy < 100) {
        if (_tick < 1) {
            _tick += _dt;
        }
        else
        {
            _energy += 10;
            _tick = 0;
        }
    }
}

-(void)death
{
    if (self.dead) {
        _deathTimer += _dt;
        if (_deathTimer < 6) {
            return;
        }
        else
        {
            [self resetMe];
        }
    }
    if (self.health <= 0) {
        if (![self actionForKey:@"death"] &&
            ![self actionForKey:@"deathLeft"]) {
            self.dead = YES;
            if (_rightDirection) {
                [self runAction:[SKAction animateWithTextures:[self animationTexturesWithKey:@"death"] timePerFrame:0.1] withKey:@"death"];
            }
            else
            {
                [self runAction:[SKAction animateWithTextures:[self animationTexturesWithKey:@"deathLeft"] timePerFrame:0.1] withKey:@"deathLeft"];
            }
        }
    }
}

-(void)deathByFall
{
    if (_fallDeath) {
        _deathTimer += _dt;
        if (_deathTimer < 1.5) {
            return;
        }
        else
        {
            [self resetMe];
            [self toBeginning];
        }
    }
    if (![self actionForKey:@"fallVoid"] &&
        ![self actionForKey:@"fallVoidLeft"]) {
        _fallDeath = YES;
        if (_rightDirection) {
            [self runAction:[SKAction animateWithTextures:[self animationTexturesWithKey:@"voidFall"] timePerFrame:3] withKey:@"fallVoid"];
        }
        else
        {
            [self runAction:[SKAction animateWithTextures:[self animationTexturesWithKey:@"voidFallLeft"] timePerFrame:3] withKey:@"fallVoidLeft"];
        }
        [[SKTAudio sharedInstance] playSoundEffect:@"void.wav"];
    }
}

-(void)resetMe
{
    _lives--;
    self.health = BAELOG_MAX_HEALTH;
    self.energy = 100;
    self.dead = NO;
    _fallDeath = NO;
    _deathTimer = 0;
}

-(void)toBeginning
{
    self.position = CGPointMake(256, 150);
}

@end
