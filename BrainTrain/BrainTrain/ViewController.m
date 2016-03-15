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
    b2 = [[StaticNeuron alloc] initWithValue:.6];

    // input
    i1 = [[StaticNeuron alloc] initWithValue:.05];
    i2 = [[StaticNeuron alloc] initWithValue:.1];

    // hidden
    h1 = [[Neuron alloc] init];
    h2 = [[Neuron alloc] init];

    [h1 addInput:i1 withWeight:.15];
    [h1 addInput:i2 withWeight:.2];
    [h1 setBias:b1];

    [h2 addInput:i1 withWeight:.25];
    [h2 addInput:i2 withWeight:.3];
    [h2 setBias:b1];

    // output
    o1 = [[Neuron alloc] init];
    o2 = [[Neuron alloc] init];

    [o1 addInput:h1 withWeight:.4];
    [o1 addInput:h2 withWeight:.45];

    [o2 addInput:h1 withWeight:.5];
    [o2 addInput:h2 withWeight:.55];

    [o1 setBias:b2];
    [o1 setBias:b2];
}

-(void) viewDidAppear:(BOOL)animated{
    [h1 forwardPass];

    NSLog(@"value: %f", [h1 latestOutput]);
}

@end
