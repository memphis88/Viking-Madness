//
//  Baelog.m
//  Viking Madness
//
//  Created by Dionysios Kakouris on 22/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import "Baelog.h"

@implementation Baelog
{
    NSArray *_walk;
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
}

-(instancetype)initWithPosition:(CGPoint)position
{
    if (self = [super initWithPosition:position]) {
        self.name = @"baelog";
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

-(NSArray *)animationTexturesWithKey:(NSString *)key
{
    if ([key isEqualToString:@"walk"]) {
        return [self walkAnimation];
    } else if ([key isEqualToString:@"climb"]) {
        return [self climbAnimation];
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
    }
    return nil;
}

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



@end
