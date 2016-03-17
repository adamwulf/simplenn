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
    NSArray* inputNeurons; // our inputs
    NSArray* outputNeurons; // our output is used as these neurons input
    NSArray* oldWeights;

    // cached output from last run
    CGFloat output;
}

+(CGFloat) learningRate{
    return .5;
}

// name of this neuron for debugging
@synthesize name;

// for forward prop
@synthesize weights;

// for backprop
@synthesize deltaNode;

-(instancetype) initWithName:(NSString*)n{
    if (self = [super init]){
        weights = @[];
        inputNeurons = @[];
        outputNeurons = @[];
        inputLatestValues = @[];
        name = n;
    }
    return self;
}

-(void) addInput:(Neuron*)neuron{
    [self addInput:neuron withWeight:.5];
}

-(void) addInput:(Neuron*)neuron withWeight:(CGFloat)weight{
    inputNeurons = [inputNeurons arrayByAddingObject:neuron];
    weights = [weights arrayByAddingObject:@(weight)];
    [neuron addOutput:self];
}


-(CGFloat) latestOutput{
    return output;
}
-(CGFloat) errorGivenTarget:(CGFloat)targetVal{
    CGFloat diff = (targetVal - output);
    return .5 * diff * diff;
}


-(CGFloat) weightForInputNeuron:(Neuron*)neuron{
    return [self weightForInputNeuron:neuron givenWeights:weights];
}

-(CGFloat) previousWeightForInputNeuron:(Neuron*)neuron{
    return [self weightForInputNeuron:neuron givenWeights:oldWeights];
}

#pragma mark - Forward and Backward Propagation

-(void) forwardPass{
    CGFloat netInput = [self calculateNetInput];
    output = [self squash:netInput];
}

-(void) backprop{
    CGFloat dErrTotaldOut = 0;
    for (int i=0; i<[outputNeurons count]; i++) {
        Neuron* outNeuron = outputNeurons[i];
        CGFloat deltaOutput = [outNeuron deltaNode];
        CGFloat outWeight = [outNeuron previousWeightForInputNeuron:self];
        CGFloat dErrOutdOut = (deltaOutput * outWeight);

        dErrTotaldOut += dErrOutdOut;
    }
    [self backpropGivendErrTotaldOut:dErrTotaldOut];
}


-(void) backpropGivenOutput:(CGFloat)targetVal{
    CGFloat dErrTotaldOut = ([self latestOutput] - targetVal);

    [self backpropGivendErrTotaldOut:dErrTotaldOut];
}

#pragma mark - Private

-(void) backpropGivendErrTotaldOut:(CGFloat)dTotaldOut{
    CGFloat dOutdNet = [self latestOutput] * (1 - [self latestOutput]);

    deltaNode = dTotaldOut * dOutdNet;

    NSArray* updatedWeights = @[];

    for (int i=0; i<[weights count]; i++) {
        CGFloat dNetdInput = [inputLatestValues[i] floatValue];
        CGFloat dTotaldinput = deltaNode * dNetdInput;
        CGFloat weight = [weights[i] floatValue];

        updatedWeights = [updatedWeights arrayByAddingObject:@(weight - [Neuron learningRate] * dTotaldinput)];
    }

    oldWeights = weights;
    weights = updatedWeights;
    
}

-(void) addOutput:(Neuron*)neuron{
    outputNeurons = [outputNeurons arrayByAddingObject:neuron];
}

-(CGFloat) weightForInputNeuron:(Neuron*)neuron givenWeights:(NSArray*)givenWeights{
    return [[givenWeights objectAtIndex:[inputNeurons indexOfObject:neuron]] floatValue];
}

#pragma mark - Private Helpers

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

    return sum;
}

-(CGFloat) squash:(CGFloat)netInput{
    return 1.0 / (1.0 + exp(-netInput));
}

-(NSString*) description{
    return [NSString stringWithFormat:@"[Neuron %@]", [self name]];
}

@end
