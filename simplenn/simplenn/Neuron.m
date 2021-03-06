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
    return .01;
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

#pragma mark - Public Methods

-(NSArray*) inputs{
    return inputNeurons;
}

-(NSArray*) outputs{
    return outputNeurons;
}

-(void) addInput:(Neuron*)neuron{
    [self addInput:neuron withWeight:.5];
}

-(void) addInput:(Neuron*)neuron withWeight:(CGFloat)weight{
    inputNeurons = [inputNeurons arrayByAddingObject:neuron];
    weights = [weights arrayByAddingObject:@(weight)];
    oldWeights = [oldWeights arrayByAddingObject:@(weight)];
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

-(void) updateWeight:(CGFloat)weight forInputNeuron:(Neuron *)neuron{
    NSMutableArray* newWeights = [NSMutableArray arrayWithArray:weights];
    [newWeights replaceObjectAtIndex:[inputNeurons indexOfObject:neuron] withObject:@(weight)];
    weights = newWeights;
}

-(CGFloat) previousWeightForInputNeuron:(Neuron*)neuron{
    return [self weightForInputNeuron:neuron givenWeights:oldWeights];
}

#pragma mark - Forward and Backward Propagation

-(void) forwardPass{
    CGFloat netInput = [self calculateNetInput];
    output = [self squash:netInput];
}

// most neurons will just use [backprop] to
// process the back propagation. The output
// neurons will need to use backpropGivenOutput:
// to begin the training.
-(CGFloat) backprop{
    if(![oldWeights count]){
        oldWeights = [weights copy];
    }
    CGFloat dErrTotaldOut = 0;
    for (int i=0; i<[outputNeurons count]; i++) {
        Neuron* outNeuron = outputNeurons[i];
        CGFloat deltaOutput = [outNeuron deltaNode];
        CGFloat outWeight = [outNeuron previousWeightForInputNeuron:self];
        CGFloat dErrOutdOut = (deltaOutput * outWeight);

        dErrTotaldOut += dErrOutdOut;
    }
    [self backpropGivendErrTotaldOut:dErrTotaldOut];
    
    return dErrTotaldOut;
}

-(CGFloat) backpropGivenOutput:(CGFloat)targetVal{
    CGFloat dErrTotaldOut = ([self latestOutput] - targetVal);

    [self backpropGivendErrTotaldOut:dErrTotaldOut];
    
    return dErrTotaldOut;
}

#pragma mark - Private Forward and Backward Propagation

-(void) backpropGivendErrTotaldOut:(CGFloat)dTotaldOut{
    CGFloat dOutdNet = [self latestOutput] * (1 - [self latestOutput]);

    deltaNode = dTotaldOut * dOutdNet;
    
    NSArray* updatedWeights = @[];

    for (int i=0; i<[weights count]; i++) {
        CGFloat dNetdInput = [inputLatestValues[i] doubleValue];
        CGFloat dTotaldinput = deltaNode * dNetdInput;
        CGFloat weight = [weights[i] doubleValue];

        updatedWeights = [updatedWeights arrayByAddingObject:@(weight - [Neuron learningRate] * dTotaldinput)];
    }

    oldWeights = weights;
    weights = updatedWeights;
    
}

-(CGFloat) calculateNetInput{
    CGFloat sum = 0;
    inputLatestValues = @[];
    for (int i=0; i<[weights count]; i++) {
        CGFloat weight = [weights[i] doubleValue];
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

#pragma mark - Private Helpers

// This way, all neurons have an array of both their inputs
// and their outputs. This helps make some calculations a bit
// easier.
-(void) addOutput:(Neuron*)neuron{
    outputNeurons = [outputNeurons arrayByAddingObject:neuron];
}

-(CGFloat) weightForInputNeuron:(Neuron*)neuron givenWeights:(NSArray*)givenWeights{
    return [[givenWeights objectAtIndex:[inputNeurons indexOfObject:neuron]] doubleValue];
}

-(NSString*) description{
    return [NSString stringWithFormat:@"[Neuron %@]", [self name]];
}

#pragma mark - NSCoding

-(instancetype) initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        weights = [aDecoder decodeObjectForKey:@"weights"];
        deltaNode = [aDecoder decodeFloatForKey:@"deltaNode"];
        name = [aDecoder decodeObjectForKey:@"name"];
        inputNeurons = [aDecoder decodeObjectForKey:@"inputNeurons"];
        outputNeurons = [aDecoder decodeObjectForKey:@"outputNeurons"];
        oldWeights = [aDecoder decodeObjectForKey:@"oldWeights"];
        output = [aDecoder decodeFloatForKey:@"output"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:weights forKey:@"weights"];
    [aCoder encodeFloat:deltaNode forKey:@"deltaNode"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:inputNeurons forKey:@"inputNeurons"];
    [aCoder encodeObject:outputNeurons forKey:@"outputNeurons"];
    [aCoder encodeObject:oldWeights forKey:@"oldWeights"];
    [aCoder encodeFloat:output forKey:@"output"];
}


@end
