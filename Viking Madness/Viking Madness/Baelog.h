//
//  Baelog.h
//  Viking Madness
//
//  Created by Dionysios Kakouris on 22/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import "Entity.h"

typedef enum {
    Punch,
    Slash,
} AttackType;

@interface Baelog : Entity

@property (nonatomic) BOOL rightDirection;
@property (nonatomic) float energy;

-(void)dealDamage:(NSMutableArray *)entities attackType:(AttackType)attack;

@end
