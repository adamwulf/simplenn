//
//  Neuron.h
//  simple-nn
//
//  Created by Adam Wulf on 3/14/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface Neuron : NSObject

@property (nonatomic, strong) Neuron* bias;
@property (nonatomic, readonly) NSArray* weights;

-(void) addInput:(Neuron*)neuron;

-(void) addInput:(Neuron*)neuron withWeight:(CGFloat)weight;

-(CGFloat) latestOutput;

-(void) forwardPass;

-(CGFloat) errorGivenTarget:(CGFloat)targetVal;

-(void) backpropGivenTarget:(CGFloat)targetVal;

@end
