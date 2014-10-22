//
//  FirstLevel.m
//  Viking Madness
//
//  Created by Dionysios Kakouris on 22/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import "FirstLevel.h"
#import "Baelog.h"

@implementation FirstLevel
{
    SKSpriteNode *_background;
    SKNode *_bgLayer;
    SKNode *_playerLayer;
    Baelog *_baelog;
    int _debug;
    NSArray *_debugArray;
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
    }
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
    return self;
}

#pragma mark Initializers

-(void)initBackground
{
    
    _background = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:self.size];
    _background.anchorPoint = CGPointZero;
    _background.position = CGPointMake(0, 0);
    [_bgLayer addChild:_background];
}

-(void)initEntities
{
    _baelog = [[Baelog alloc] initWithPosition:CGPointMake(self.size.width/2, self.size.height/2)];
    [_baelog runAction:[SKAction scaleTo:5.0 duration:0]];
    [_playerLayer addChild:_baelog];
}

-(void)initTerrain
{
    
}

-(SKAction *)animateWithKey:(NSString *)key
{
    SKAction *action;
    action = [SKAction animateWithTextures:[_baelog animationTexturesWithKey:key] timePerFrame:0.1];
    return action;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UITouch *touch = [touches anyObject];
    //CGPoint touchLocation = [touch locationInNode:_bgLayer];
    [self dummyAnimationDebug];
}

-(void)dummyAnimationDebug
{
    [_baelog removeActionForKey:_debugArray[_debug]];
    [_baelog runAction:[SKAction repeatActionForever:[self animateWithKey:_debugArray[_debug]]] withKey:_debugArray[_debug]];
    _debug++;
    if (_debug > 12) {
        _debug = 0;
    }
}

@end
