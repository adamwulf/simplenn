//
//  MMWeight.m
//  simple-nn-vis
//
//  Created by Adam Wulf on 3/18/16.
//  Copyright © 2016 Milestone made. All rights reserved.
//

#import "MMWeight.h"

@implementation MMWeight

+(MMStick*) weightWithP0:(MMPoint*)p0 andP1:(MMPoint*)p1{
    return [[MMWeight alloc] initWithP0:p0 andP1:p1];
}

-(id) initWithP0:(MMPoint *)_p0 andP1:(MMPoint *)_p1{
    if(self = [super initWithP0:_p0 andP1:_p1]){
        // noop
    }
    return self;
}

-(void) setLength:(CGFloat)_length{
    [super setLength:_length];
}

-(void) constrain{
    // noop
}

-(CGFloat) stress{
    // .0 => blue
    // .1 => red
    return 0;
}

-(MMPhysicsObject*) cloneObject{
    return [MMWeight weightWithP0:[MMPoint pointWithCGPoint:self.p0.asCGPoint]
                            andP1:[MMPoint pointWithCGPoint:self.p1.asCGPoint]];
}


@end
