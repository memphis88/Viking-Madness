//
//  Knight.h
//  Viking Madness
//
//  Created by Dion Kak on 29/10/14.
//  Copyright (c) 2014 iOSP. All rights reserved.
//

#import "Entity.h"

@interface Knight : Entity

@property (nonatomic, copy) NSString *patrolWidth;

-(void)startPatrol;

@end
