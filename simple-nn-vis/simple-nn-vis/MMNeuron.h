//
//  MMBalloon.h
//  physics-2D-Verlet
//
//  Created by Adam Wulf on 3/26/15.
//  Copyright (c) 2015 Milestone made. All rights reserved.
//

#import "MMPoint.h"
#import "MMStick.h"
#import "MMPhysicsObject.h"

@interface MMNeuron : MMPhysicsObject<NSCoding>

@property (readonly) MMPoint* center;
@property (readonly) MMPoint* tail;
@property (nonatomic) CGFloat radius;

+(MMNeuron*) balloonWithCGPoint:(CGPoint)p;

-(void) constrainCollisionsWith:(NSArray*)objs;

@end
