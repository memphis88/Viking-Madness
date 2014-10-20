//
//  MyScene.m
//  Viking Madness
//
//  Created by Dionysios Kakouris on 20/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene
{
    SKSpriteNode *_background;
    SKSpriteNode *_logo;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self initBackground];
        [self addChild:_background];
        [self addChild:_logo];
    }
    return self;
}

-(void)initBackground
{
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"mainMenu.png"];
    _background.anchorPoint = CGPointMake(0.5, 1);
    _background.xScale = 1.85;
    _background.yScale = 1.85;
    _background.position = CGPointMake(self.size.width/2, self.size.height);
    
    _logo = [SKSpriteNode spriteNodeWithImageNamed:@"logo.png"];
    _logo.anchorPoint = CGPointMake(0.5, 1);
    _logo.xScale = 1.85;
    _logo.yScale = 1.85;
    _logo.position = CGPointMake(self.size.width/2, self.size.height);
    
    SKAction *hide = [SKAction customActionWithDuration:0.5 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        node.hidden = YES;
    }];
    
    SKAction *show = [SKAction customActionWithDuration:1.0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        node.hidden = NO;
    }];
    
    SKAction *blinkSequence = [SKAction repeatActionForever:[SKAction sequence:@[hide, show]]];
    [_logo runAction:blinkSequence];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
