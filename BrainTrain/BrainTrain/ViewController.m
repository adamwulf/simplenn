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
#import <mach/mach_time.h>  // for mach_absolute_time() and friends

@interface ViewController ()<MMSidebarViewDelegate>

@property (nonatomic, strong) IBOutlet NeuralView* neuralView;
@property (nonatomic, strong) IBOutlet MMSidebarView* sidebarView;

@end

@implementation ViewController{
    CADisplayLink* link;
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
    Neuron* b1 = [[StaticNeuron alloc] initWithName:@"b1" andValue:.35];
    Neuron* b2 = [[StaticNeuron alloc] initWithName:@"b2" andValue:1.0];

    // input
    Neuron* i1 = [[StaticNeuron alloc] initWithName:@"i1" andValue:.05];
    Neuron* i2 = [[StaticNeuron alloc] initWithName:@"i2" andValue:.1];

    // hidden
    Neuron* h1 = [[Neuron alloc] initWithName:@"h1"];
    Neuron* h2 = [[Neuron alloc] initWithName:@"h2"];
    Neuron* h3 = [[Neuron alloc] initWithName:@"h3"];

    [h1 addInput:i1 withWeight:.15];
    [h1 addInput:i2 withWeight:.2];
    [h1 addInput:b1];

    [h2 addInput:i1 withWeight:.25];
    [h2 addInput:i2 withWeight:.3];
    [h2 addInput:b1];

    // output
    Neuron* o1 = [[Neuron alloc] initWithName:@"o1"];
    Neuron* o2 = [[Neuron alloc] initWithName:@"o2"];

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

    [h3 addInput:o1];
    [h1 addInput:h3];

    [neuralView addNeuron:i1 type:NeuronInput];
    [neuralView addNeuron:i2 type:NeuronInput];
    [neuralView addNeuron:h1 type:NeuronHidden];
    [neuralView addNeuron:h2 type:NeuronHidden];
    [neuralView addNeuron:h3 type:NeuronHidden];
    [neuralView addNeuron:o1 type:NeuronOutput];
    [neuralView addNeuron:o2 type:NeuronOutput];
    [neuralView addNeuron:b1 type:NeuronHidden];
    [neuralView addNeuron:b2 type:NeuronHidden];
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

            NSMutableSet* allNeurons = [NSMutableSet setWithArray:neuralView.neurons];
            NSMutableArray* nextNeuronsToPass = [NSMutableArray arrayWithArray:neuralView.inputs];
            [allNeurons minusSet:[NSSet setWithArray:nextNeuronsToPass]];


            while([nextNeuronsToPass count]) {
                Neuron* neuron = [nextNeuronsToPass firstObject];
                [nextNeuronsToPass removeObjectAtIndex:0];


                [neuron forwardPass];

                NSMutableSet* nextNeurons = [allNeurons mutableCopy];
                [nextNeurons intersectSet:[NSSet setWithArray:neuron.outputs]];
                [nextNeuronsToPass addObjectsFromArray:[nextNeurons allObjects]];
                [allNeurons minusSet:nextNeurons];
            }


            if(i%10000 == 0){
                NSLog(@"run %ld", i + 1);
                NSLog(@"  o1: %f", [neuralView.outputs[0] latestOutput]);
                NSLog(@"  o2: %f", [neuralView.outputs[1] latestOutput]);
            }

            CGFloat e1 = [neuralView.outputs[0] errorGivenTarget:o1Target];
            CGFloat e2 = [neuralView.outputs[1] errorGivenTarget:o2Target];

//            NSLog(@"  e1: %f", e1);
//            NSLog(@"  e2: %f", e2);

            CGFloat errorTotal = e1 + e2;

//            if(i%100 == 0){
//                NSLog(@"  e total: %f", errorTotal);
//            }

//            if(errorTotal <= 0.000035085){
                // Can I beat the error rate in the tutorial
                // in fewer than 10,000 iterations???!
//                NSLog(@"error <= 0.000035085");
//            }

//            NSLog(@"  pre-o2.bias: %f", [o1 weightForInputNeuron:b2]);
//            NSLog(@"  pre-o2.bias: %f", [o2 weightForInputNeuron:b2]);


            allNeurons = [NSMutableSet setWithArray:neuralView.neurons];
            nextNeuronsToPass = [NSMutableArray arrayWithArray:neuralView.outputs];
            [allNeurons minusSet:[NSSet setWithArray:nextNeuronsToPass]];

            while([nextNeuronsToPass count]) {
                Neuron* neuron = [nextNeuronsToPass firstObject];
                [nextNeuronsToPass removeObjectAtIndex:0];


                if(neuron == neuralView.outputs[0]){
                    [neuron backpropGivenOutput:o1Target];
                }else if(neuron == neuralView.outputs[1]){
                    [neuron backpropGivenOutput:o2Target];
                }else{
                    [neuron backprop];
                }


                NSMutableSet* nextNeurons = [allNeurons mutableCopy];
                [nextNeurons intersectSet:[NSSet setWithArray:neuron.inputs]];
                [nextNeuronsToPass addObjectsFromArray:[nextNeurons allObjects]];
                [allNeurons minusSet:nextNeurons];
            }



            for (Neuron* neuron in [neuralView.neurons reverseObjectEnumerator]) {
                if(neuron == neuralView.outputs[0]){
                    [neuron backpropGivenOutput:o1Target];
                }else if(neuron == neuralView.outputs[1]){
                    [neuron backpropGivenOutput:o2Target];
                }else{
                    [neuron backprop];
                }
            }

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

-(NSString*)filename{
    return [[ViewController documentsPath] stringByAppendingPathComponent:@"foo.data"];
}

-(void) save{
    NSDictionary* data;
    @synchronized(self) {
        data = [neuralView asDictionary];
    }
    [NSKeyedArchiver archiveRootObject:data toFile:[self filename]];
}

-(void) load{
    NSDictionary* dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filename]];
    if(dictionary){
        @synchronized(self) {
            [neuralView loadDictionary:dictionary];
        }
    }
}


static NSArray* userDocumentsPaths;
+(NSString*) documentsPath{
    if(!userDocumentsPaths){
        userDocumentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    }
    return [userDocumentsPaths objectAtIndex:0];
}




CGFloat BNRTimeBlock2 (void (^block)(void)) {
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;

    uint64_t start = mach_absolute_time ();
    block ();
    uint64_t end = mach_absolute_time ();
    uint64_t elapsed = end - start;

    uint64_t nanos = elapsed * info.numer / info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;

} // BNRTimeBlock

@end
