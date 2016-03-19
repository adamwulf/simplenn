//
//  ViewController.m
//  BrainTrain
//
//  Created by Adam Wulf on 3/14/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import "ViewController.h"
#import <simplenn/simplenn.h>
#import "NeuralView.h"
#import "MMSidebarView.h"
#import "MMSidebarViewDelegate.h"
#import "InstantPanGestureRecognizer.h"

@interface ViewController ()<MMSidebarViewDelegate>

@property (nonatomic, strong) IBOutlet NeuralView* neuralView;
@property (nonatomic, strong) IBOutlet MMSidebarView* sidebarView;

@end

@implementation ViewController{
    CADisplayLink* link;

    Neuron* b1;
    Neuron* b2;

    Neuron* i1;
    Neuron* i2;

    Neuron* h1;
    Neuron* h2;

    Neuron* o1;
    Neuron* o2;
}

@synthesize neuralView;

- (void)viewDidLoad {
    [super viewDidLoad];

    UIScreenEdgePanGestureRecognizer* edgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgePan:)];
    edgePanGesture.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:edgePanGesture];


    link = [CADisplayLink displayLinkWithTarget:neuralView selector:@selector(setNeedsDisplay)];
    link.frameInterval = 2;
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

    // bias
    b1 = [[StaticNeuron alloc] initWithName:@"b1" andValue:.35];
    b2 = [[StaticNeuron alloc] initWithName:@"b2" andValue:1.0];

    // input
    i1 = [[StaticNeuron alloc] initWithName:@"i1" andValue:.05];
    i2 = [[StaticNeuron alloc] initWithName:@"i2" andValue:.1];

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

    [o1 addInput:i1 withWeight:.5];
    [o1 addInput:i2 withWeight:.55];
    [o1 addInput:h1 withWeight:.4];
    [o1 addInput:h2 withWeight:.45];
    [o1 addInput:b2];

    [o2 addInput:i1 withWeight:.5];
    [o2 addInput:i2 withWeight:.55];
    [o2 addInput:h1 withWeight:.5];
    [o2 addInput:h2 withWeight:.55];
    [o2 addInput:b2];

    [neuralView addNeuron:i1];
    [neuralView addNeuron:i2];
    [neuralView addNeuron:h1];
    [neuralView addNeuron:h2];
    [neuralView addNeuron:o1];
    [neuralView addNeuron:o2];
    [neuralView addNeuron:b1];
    [neuralView addNeuron:b2];
}

-(void) viewDidAppear:(BOOL)animated{
    [self performSelectorInBackground:@selector(train) withObject:nil];

    [self.view setNeedsDisplay];
}

-(void) train{
    CGFloat o1Target = .01;
    CGFloat o2Target = .99;

    NSInteger i=0;
    while(YES){
        @synchronized(self) {
            [h1 forwardPass];
            [h2 forwardPass];
            [o1 forwardPass];
            [o2 forwardPass];

//            if(i%10000 == 0){
//                NSLog(@"run %ld", i + 1);
//                NSLog(@"  o1: %f", [o1 latestOutput]);
//                NSLog(@"  o2: %f", [o2 latestOutput]);
//            }

            CGFloat e1 = [o1 errorGivenTarget:o1Target];
            CGFloat e2 = [o2 errorGivenTarget:o2Target];

//            NSLog(@"  e1: %f", e1);
//            NSLog(@"  e2: %f", e2);

            CGFloat errorTotal = e1 + e2;

//            if(i%100 == 0){
//                NSLog(@"  e total: %f", errorTotal);
//            }

            if(errorTotal <= 0.000035085){
                // Can I beat the error rate in the tutorial
                // in fewer than 10,000 iterations???!
//                NSLog(@"error <= 0.000035085");
            }

//            NSLog(@"  pre-o2.bias: %f", [o1 weightForInputNeuron:b2]);
//            NSLog(@"  pre-o2.bias: %f", [o2 weightForInputNeuron:b2]);

            [o1 backpropGivenOutput:o1Target];
            [o2 backpropGivenOutput:o2Target];
            [h1 backprop];
            [h2 backprop];

//            NSLog(@"  post-o2.bias: %f", [o1 weightForInputNeuron:b2]);
//            NSLog(@"  post-o2.bias: %f", [o2 weightForInputNeuron:b2]);

            i++;
        }
    }
}

#pragma mark - Gestures

-(void) edgePan:(UIScreenEdgePanGestureRecognizer*)edgeGesture{
    if(edgeGesture.state == UIGestureRecognizerStateRecognized){
        [UIView animateWithDuration:.3 animations:^{
            CGRect r = self.sidebarView.bounds;
            r.origin.x = self.view.bounds.size.width - self.sidebarView.bounds.size.width;
            self.sidebarView.frame = r;
        }];
    }
}

#pragma mark - MMSidebarViewDelegate

-(void)sidebarShouldClose{
    [UIView animateWithDuration:.3 animations:^{
        CGRect r = self.sidebarView.bounds;
        r.origin.x = self.view.bounds.size.width;
        self.sidebarView.frame = r;
    }];
}

-(void) resetRandomWeight{
    [neuralView resetRandomWeight];
}

@end
