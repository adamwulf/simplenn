//
//  NeuralView.h
//  BrainTrain
//
//  Created by Adam Wulf on 3/17/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <simplenn/simplenn.h>

typedef enum NSInteger{
    NeuronInput,
    NeuronOutput,
    NeuronHidden
} NeuronType;

@interface NeuralView : UIView

@property (nonatomic, readonly) NSArray* inputs;
@property (nonatomic, readonly) NSArray* neurons;
@property (nonatomic, readonly) NSArray* outputs;

@property (nonatomic, strong) UIColor* unselectedColor;
@property (nonatomic, strong) UIColor* selectedInputColor;
@property (nonatomic, strong) UIColor* selectedOutputColor;
@property (nonatomic, strong) UIColor* selectedWeightColor;

-(void) addNeuron:(Neuron*)neuron type:(NeuronType)type;

-(void) resetRandomWeight;

-(NSDictionary*) asDictionary;

-(void) loadDictionary:(NSDictionary*)data;

@end
