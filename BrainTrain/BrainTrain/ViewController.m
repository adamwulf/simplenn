//
//  ViewController.m
//  BrainTrain
//
//  Created by Adam Wulf on 3/14/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import "ViewController.h"
#import <simplenn/simplenn.h>


@interface ViewController ()

@end

@implementation ViewController{
    Neuron* b1;
    Neuron* b2;

    Neuron* i1;
    Neuron* i2;

    Neuron* h1;
    Neuron* h2;

    Neuron* o1;
    Neuron* o2;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // bias
    b1 = [[StaticNeuron alloc] initWithValue:.35];
    b2 = [[StaticNeuron alloc] initWithValue:1.0];

    // input
    i1 = [[StaticNeuron alloc] initWithValue:.05];
    i2 = [[StaticNeuron alloc] initWithValue:.1];

    // hidden
    h1 = [[Neuron alloc] initWithName:@"h1"];
    h2 = [[Neuron alloc] initWithName:@"h2"];

    [h1 addInput:i1 withWeight:.15];
    [h1 addInput:i2 withWeight:.2];
    [h1 addInput:b1];

    [h2 addInput:i1 withWeight:.25];
    [h2 addInput:i2 withWeight:.3];
    [h2 addInput:b1];

    // output
    o1 = [[Neuron alloc] initWithName:@"o1"];
    o2 = [[Neuron alloc] initWithName:@"o2"];

    [o1 addInput:h1 withWeight:.4];
    [o1 addInput:h2 withWeight:.45];
    [o1 addInput:b2];

    [o2 addInput:h1 withWeight:.5];
    [o2 addInput:h2 withWeight:.55];
    [o2 addInput:b2];
}

-(void) viewDidAppear:(BOOL)animated{

    CGFloat o1Target = .01;
    CGFloat o2Target = .99;


    for (int i=0; i<10000; i++) {
        NSLog(@"run %i", i + 1);
        [h1 forwardPass];
        [h2 forwardPass];
        [o1 forwardPass];
        [o2 forwardPass];

        NSLog(@"  o1: %f", [o1 latestOutput]);
        NSLog(@"  o2: %f", [o2 latestOutput]);

        CGFloat e1 = [o1 errorGivenTarget:o1Target];
        CGFloat e2 = [o2 errorGivenTarget:o2Target];

        NSLog(@"  e1: %f", e1);
        NSLog(@"  e2: %f", e2);

        CGFloat errorTotal = e1 + e2;

        NSLog(@"  e total: %f", errorTotal);

        if(errorTotal <= 0.000035085){
            NSLog(@"error <= 0.000035085");
        }

        NSLog(@"  pre-o2.bias: %f", [o1 weightForInputNeuron:b2]);
        NSLog(@"  pre-o2.bias: %f", [o2 weightForInputNeuron:b2]);

        [o1 backpropGivenOutput:o1Target];
        [o2 backpropGivenOutput:o2Target];
        [h1 backprop];
        [h2 backprop];

        NSLog(@"  post-o2.bias: %f", [o1 weightForInputNeuron:b2]);
        NSLog(@"  post-o2.bias: %f", [o2 weightForInputNeuron:b2]);
    }
}

@end
