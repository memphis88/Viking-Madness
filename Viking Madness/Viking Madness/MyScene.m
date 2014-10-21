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
    SKSpriteNode *_playButton;
    SKSpriteNode *_optionsButton;
    SKLabelNode *_play;
    SKLabelNode *_options;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self initBackground];
        [self initButtons];
        [self initLabels];
        
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
    
    [self addChild:_background];
    [self addChild:_logo];
}

-(void)initButtons
{
    _playButton = [SKSpriteNode spriteNodeWithImageNamed:@"signButton.png"];
    _playButton.xScale = 0.8;
    _playButton.yScale = 0.5;
    _playButton.position = CGPointMake(self.size.width/2, self.size.height/10 * 3);
    
    _optionsButton = [SKSpriteNode spriteNodeWithImageNamed:@"signButton.png"];
    _optionsButton.xScale = 0.8;
    _optionsButton.yScale = 0.5;
    _optionsButton.position = CGPointMake(self.size.width/2, self.size.height/10 * 2);
    
    [self addChild:_playButton];
    [self addChild:_optionsButton];
}

-(void)initLabels
{
    _play = [SKLabelNode labelNodeWithFontNamed:@"bubble & soap"];
    _play.text = @"Play!";
    _play.fontSize = 60.0f;
    _play.fontColor = [SKColor redColor];
    _play.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _play.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _play.position = _playButton.position;
    
    _options = [SKLabelNode labelNodeWithFontNamed:@"bubble & soap"];
    _options.text = @"Options";
    _options.fontSize = 60.0f;
    _options.fontColor = [SKColor redColor];
    _options.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _options.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _options.position = _optionsButton.position;
    
    [self addChild:_play];
    [self addChild:_options];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
