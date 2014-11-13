//
//  Entity.h
//  XBlaster Tutorial
//
//  Created by Dionysios Kakouris on 21/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Entity : SKSpriteNode

@property (assign, nonatomic) CGPoint direction;
@property (assign, nonatomic) float health;
@property (assign, nonatomic) float maxHealth;
@property (nonatomic) BOOL dead;

+(SKTexture *)generateTexture;
-(instancetype)initWithPosition:(CGPoint)position;
-(void)update:(CFTimeInterval)delta;
-(NSArray *)animationTexturesWithKey:(NSString *)key;
-(void)didEvaluateActions;
-(void)takeDamage:(float)damage;

@end
