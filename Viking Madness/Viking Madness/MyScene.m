//
//  MyScene.m
//  Viking Madness
//
//  Created by Dionysios Kakouris on 20/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import "MyScene.h"
#import "FirstLevel.h"

@implementation MyScene
{
    SKSpriteNode *_background;
    SKSpriteNode *_logo;
    SKSpriteNode *_playButton;
    SKSpriteNode *_optionsButton;
    SKSpriteNode *_storyButton;
    SKSpriteNode *_brawlerButton;
    
    SKNode *_buttons;
    
    SKLabelNode *_play;
    SKLabelNode *_options;
    SKLabelNode *_story;
    SKLabelNode *_brawler;
    
    SKAction *_fade;
    SKAction *_tilt;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        [self initBackground];
        [self initButtons];
        [self initLabels];
        [self initActions];
        
    }
    return self;
}



-(void)initBackground
{
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"mainMenu.png"];
    _background.anchorPoint = CGPointZero;
    _background.position = CGPointZero;
    
    _logo = [SKSpriteNode spriteNodeWithImageNamed:@"logo.png"];
    _logo.anchorPoint = CGPointZero;
    _logo.position = CGPointZero;
    
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
    _playButton.name = @"playButton";
    _playButton.xScale = 0.9;
    _playButton.yScale = 0.4;
    _playButton.position = CGPointMake(self.size.width/2, self.size.height/10 * 3);
    
    _optionsButton = [SKSpriteNode spriteNodeWithImageNamed:@"signButton.png"];
    _optionsButton.name = @"optionsButton";
    _optionsButton.xScale = 0.9;
    _optionsButton.yScale = 0.4;
    _optionsButton.position = CGPointMake(self.size.width/2, self.size.height/10 * 2);
    _optionsButton.color = [SKColor grayColor];
    _optionsButton.colorBlendFactor = 1.0;
    
    _storyButton = [SKSpriteNode spriteNodeWithImageNamed:@"signButton.png"];
    _storyButton.name = @"storyButton";
    _storyButton.xScale = 0.9;
    _storyButton.yScale = 0.4;
    _storyButton.position = CGPointMake(self.size.width/2, self.size.height/10 * 3);
    
    _brawlerButton = [SKSpriteNode spriteNodeWithImageNamed:@"signButton.png"];
    _brawlerButton.name = @"brawlerButton";
    _brawlerButton.xScale = 0.9;
    _brawlerButton.yScale = 0.4;
    _brawlerButton.position = CGPointMake(self.size.width/2, self.size.height/10 * 2);
    _brawlerButton.color = [SKColor grayColor];
    _brawlerButton.colorBlendFactor = 1.0;
    
    _buttons = [SKNode node];
    [self addChild:_buttons];
    [_buttons addChild:_playButton];
    [_buttons addChild:_optionsButton];
}

-(void)initLabels
{
    _play = [SKLabelNode labelNodeWithFontNamed:@"bubble & soap"];
    _play.name = @"play";
    _play.text = @"Play!";
    _play.fontSize = 60.0f;
    _play.fontColor = [SKColor redColor];
    _play.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _play.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _play.position = _playButton.position;
    
    _options = [SKLabelNode labelNodeWithFontNamed:@"bubble & soap"];
    _options.name = @"options";
    _options.text = @"Options";
    _options.fontSize = 60.0f;
    _options.fontColor = [SKColor grayColor];
    _options.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _options.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _options.position = _optionsButton.position;
    
    _story = [SKLabelNode labelNodeWithFontNamed:@"bubble & soap"];
    _story.name = @"story";
    _story.text = @"Story Mode";
    _story.fontSize = 60.0f;
    _story.fontColor = [SKColor redColor];
    _story.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _story.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _story.position = _storyButton.position;
    
    _brawler = [SKLabelNode labelNodeWithFontNamed:@"bubble & soap"];
    _brawler.name = @"brawler";
    _brawler.text = @"Brawler Mode";
    _brawler.fontSize = 60.0f;
    _brawler.fontColor = [SKColor grayColor];
    _brawler.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _brawler.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _brawler.position = _brawlerButton.position;
    
    [_buttons addChild:_play];
    [_buttons addChild:_options];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    //dummy scene call
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:location];
    for (SKNode *node in nodes) {
        //go through nodes, get the zPosition if you want
        //int nodePos = node.zPosition;
        
        //or check the node against your nodes
        if ([node.name isEqualToString:@"play"] || [node.name isEqualToString:@"playButton"]) {
            [self playPressed];
            break;
        }
        if ([node.name isEqualToString:@"story"] || [node.name isEqualToString:@"storyButton"]) {
            SKAction *block = [SKAction runBlock:^{
                FirstLevel *myScene = [[FirstLevel alloc] initWithSize:self.size];
                SKTransition *reveal = [SKTransition doorsOpenHorizontalWithDuration:0.5];
                [self.view presentScene:myScene transition:reveal];
            }];
            [self runAction:block];
        }
    }
    
    //end
}

-(void)initActions
{
    _fade = [SKAction fadeOutWithDuration:0.5];
}

-(void)playPressed
{
    [_buttons runAction:[SKAction sequence:@[_fade,
                                             [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        [_buttons removeAllChildren];
        [_buttons addChild:_storyButton];
        [_buttons addChild:_brawlerButton];
        [_buttons addChild:_story];
        [_buttons addChild:_brawler];
    }],
                                             [SKAction fadeInWithDuration:0.5]]]];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
