//
//  StaticNeuron.h
//  simplenn
//
//  Created by Adam Wulf on 3/14/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import <simplenn/simplenn.h>

@interface StaticNeuron : Neuron

@property (nonatomic, assign) CGFloat value;

-(instancetype) initWithName:(NSString*)name andValue:(CGFloat)val;

@end
