//
//  Entity.m
//  XBlaster Tutorial
//
//  Created by Dionysios Kakouris on 21/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import "Entity.h"

@implementation Entity

-(instancetype)initWithPosition:(CGPoint)position
{
    if (self = [super init]) {
        self.texture = [[self class] generateTexture];
        self.size = self.texture.size;
        self.position = position;
        _direction = CGPointZero;
    }
    return self;
}

-(void)update:(CFTimeInterval)delta
{
    //Overridden by subs
}

+(SKTexture *)generateTexture
{
    //Overridden by subs
    return nil;
}

-(NSArray *)animationTexturesWithKey:(NSString *)key
{
    //Overridden by subs
    return nil;
}

@end
