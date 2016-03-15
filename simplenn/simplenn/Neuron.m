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

@synthesize name;

// for forward prop
@synthesize weights;
@synthesize bias;

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

-(void) addOutput:(Neuron*)neuron{
    outputNeurons = [outputNeurons arrayByAddingObject:neuron];
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


-(CGFloat) weightForNeuron:(Neuron*)neuron{
    return [[oldWeights objectAtIndex:[inputNeurons indexOfObject:neuron]] floatValue];
}


-(void) backprop{
    CGFloat dErrTotaldOut = 0;
    for (int i=0; i<[outputNeurons count]; i++) {
        Neuron* outNeuron = outputNeurons[i];
        CGFloat deltaOutput = [outNeuron deltaNode];
        CGFloat outWeight = [outNeuron weightForNeuron:self];
        CGFloat dErrOutdOut = (deltaOutput * outWeight);

        dErrTotaldOut += dErrOutdOut;
    }
    [self backpropGivendErrTotaldOut:dErrTotaldOut];
}


-(void) backpropGivenOutput:(CGFloat)targetVal{
    CGFloat dErrTotaldOut = ([self latestOutput] - targetVal);

    [self backpropGivendErrTotaldOut:dErrTotaldOut];
}


-(void) backpropGivendErrTotaldOut:(CGFloat)dTotaldOut{
    CGFloat dOutdNet = [self latestOutput] * (1 - [self latestOutput]);

    deltaNode = dTotaldOut * dOutdNet;

    NSArray* updatedWeights = @[];

    for (int i=0; i<[weights count]; i++) {
        CGFloat dNetdInput = [inputLatestValues[i] floatValue];
        CGFloat dTotaldinput = deltaNode * dNetdInput;
        CGFloat weight = [weights[i] floatValue];

        updatedWeights = [updatedWeights arrayByAddingObject:@(weight - [Neuron learningRate] *dTotaldinput)];
    }
    
    oldWeights = weights;
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

-(NSString*) description{
    return [NSString stringWithFormat:@"[Neuron %@]", [self name]];
}

@end
