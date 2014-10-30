//
//  Knight.m
//  Viking Madness
//
//  Created by Dion Kak on 29/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import "Knight.h"

@implementation Knight
{
    NSArray *_walkLeft;
    NSArray *_walkRight;
    NSArray *_slashLeft;
    NSArray *_slashRight;
}

-(instancetype)initWithPosition:(CGPoint)position
{
    if (self = [super initWithPosition:position]) {
        self.name = @"knight";
    }
    return self;
}

+(SKTexture *)generateTexture
{
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKSpriteNode *baelog = [SKSpriteNode spriteNodeWithImageNamed:@"Knight_Walk_00"];
        SKView *textureView = [SKView new];
        texture = [textureView textureFromNode:baelog];
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

@end
