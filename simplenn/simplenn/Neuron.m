//
//  Neuron.m
//  simple-nn
//
//  Created by Adam Wulf on 3/14/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import "Neuron.h"

@implementation Neuron{
    NSArray* inputLatestValues;
    NSArray* inputNeurons;

    // cached output from last run
    CGFloat output;
}

+(CGFloat) learningRate{
    return .5;
}

@synthesize weights;
@synthesize bias;

-(instancetype) init{
    if (self = [super init]){
        weights = @[];
        inputNeurons = @[];
        inputLatestValues = @[];
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

-(void) forwardPass{
    CGFloat netInput = [self calculateNetInput];
    output = [self squash:netInput];
}

-(CGFloat) latestOutput{
    return output;
}

-(CGFloat) errorGivenTarget:(CGFloat)targetVal{
    CGFloat diff = (targetVal - output);
    return .5 * diff * diff;
}

-(void) backpropGivenTarget:(CGFloat)targetVal{

    CGFloat dTotaldOut = ([self latestOutput] - targetVal);

    NSLog(@"error total: %f", dTotaldOut);

    CGFloat dOutdNet = [self latestOutput] * (1 - [self latestOutput]);

    NSLog(@"error dnet: %f", dOutdNet);

    CGFloat deltaNode = dTotaldOut * dOutdNet;

    NSArray* updatedWeights = @[];

    for (int i=0; i<[weights count]; i++) {
        CGFloat dNetdInput = [inputLatestValues[i] floatValue];


        NSLog(@"dnetdinput %i: %f", i, dNetdInput);

        CGFloat dTotaldinput = deltaNode * dNetdInput;

        NSLog(@"dTotaldinput %i: %f", i, dTotaldinput);

        CGFloat weight = [weights[i] floatValue];

        updatedWeights = [updatedWeights arrayByAddingObject:@(weight - [Neuron learningRate] *dTotaldinput)];
    }

    weights = updatedWeights;
}

#pragma mark - private

-(CGFloat) calculateNetInput{
    CGFloat sum = 0;
    inputLatestValues = @[];
    for (int i=0; i<[weights count]; i++) {
        CGFloat weight = [weights[i] floatValue];
        Neuron* input = inputNeurons[i];
        CGFloat inputValue = [input latestOutput];
        sum += weight * inputValue;
        inputLatestValues = [inputLatestValues arrayByAddingObject:@(inputValue)];
    }
    sum += [bias latestOutput];

    return sum;
}

-(CGFloat) squash:(CGFloat)netInput{
    return 1.0 / (1.0 + exp(-netInput));
}

@end
