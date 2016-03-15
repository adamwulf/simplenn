//
//  StaticNeuron.m
//  simplenn
//
//  Created by Adam Wulf on 3/14/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import "StaticNeuron.h"

@implementation StaticNeuron{
    CGFloat value;
}

-(instancetype) initWithValue:(CGFloat)val{
    if(self = [super init]){
        value = val;
    }
    return self;
}

-(CGFloat)latestOutput{
    return value;
}

@end
