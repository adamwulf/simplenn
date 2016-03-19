//
//  NeuralView.h
//  BrainTrain
//
//  Created by Adam Wulf on 3/17/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <simplenn/simplenn.h>


@interface NeuralView : UIView

@property (nonatomic, readonly) NSArray* neurons;

-(void) addNeuron:(Neuron*)neuron;

-(void) resetRandomWeight;

-(NSDictionary*) asDictionary;

-(void) loadDictionary:(NSDictionary*)data;

@end
