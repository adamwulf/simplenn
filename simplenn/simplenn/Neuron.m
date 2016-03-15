//
//  Neuron.m
//  simple-nn
//
//  Created by Adam Wulf on 3/14/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import "Neuron.h"

@implementation Neuron{
    NSArray* weights;
    NSArray* inputNeurons;

    // cached output from last run
    CGFloat output;
}

@synthesize bias;

-(instancetype) init{
    if (self = [super init]){
        weights = @[];
        inputNeurons = @[];
    }
    return self;
}

-(void) addInput:(Neuron*)neuron{
    [self addInput:neuron withWeight:.5];
}

-(void) addInput:(Neuron*)neuron withWeight:(CGFloat)weight{
    inputNeurons = [inputNeurons arrayByAddingObject:neuron];
    weights = [weights arrayByAddingObject:@(weight)];
}

-(CGFloat) latestOutput{
    return output;
}

-(void) forwardPass{
    output = [self calculateNetInput];
}

#pragma mark - private

-(CGFloat) calculateNetInput{
    CGFloat sum = 0;
    for (int i=0; i<[weights count]; i++) {
        CGFloat weight = [weights[i] floatValue];
        Neuron* input = inputNeurons[i];
        sum += weight * [input latestOutput];
    }
    sum += [bias latestOutput];

    return sum;
}

@end
