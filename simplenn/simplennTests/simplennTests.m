//
//  simplennTests.m
//  simplennTests
//
//  Created by Adam Wulf on 10/12/17.
//  Copyright © 2017 Milestone Made. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <simplenn/simplenn.h>

@interface simplennTests : XCTestCase

@end

@implementation simplennTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXOR {
    // bias
    Neuron* bias = [[StaticNeuron alloc] initWithName:@"b2" andValue:1.0];
    
    // input
    StaticNeuron* i1 = [[StaticNeuron alloc] initWithName:@"i1" andValue:.05];
    StaticNeuron* i2 = [[StaticNeuron alloc] initWithName:@"i2" andValue:.1];
    
    // hidden
    Neuron* h1 = [[Neuron alloc] initWithName:@"h1"];
    Neuron* h2 = [[Neuron alloc] initWithName:@"h2"];
    Neuron* o1 = [[Neuron alloc] initWithName:@"o1"];
    
    [o1 addInput:h1 withWeight:.1];
    [o1 addInput:h2 withWeight:.1];

    [h1 addInput:i1 withWeight:.1];
    [h1 addInput:i2 withWeight:.1];

    [h2 addInput:i1 withWeight:.1];
    [h2 addInput:i2 withWeight:.1];

    [h1 addInput:bias withWeight:.1];
    [h2 addInput:bias withWeight:.1];
    [o1 addInput:bias withWeight:.1];
    
    NSArray* data = @[@[@0, @0, @0],
                      @[@1, @0, @1],
                      @[@0, @1, @1],
                      @[@1, @1, @0]];
    CGFloat avgError = 0;

    for (NSInteger i=0; i<1000; i++) {
        NSArray* testCase = data[i % [data count]];
        
        [i1 setValue:[testCase[0] doubleValue]];
        [i2 setValue:[testCase[1] doubleValue]];
        
        [h1 forwardPass];
        [h2 forwardPass];
        [o1 forwardPass];

        CGFloat target = [testCase[2] doubleValue];
        
        [o1 backpropGivenOutput:target];
        [h1 backprop];
        [h2 backprop];

        avgError = avgError * 0.75 + [o1 deltaNode] * 0.25;

        NSLog(@"Error: %f", avgError);
    }
}

@end
