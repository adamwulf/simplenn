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

-(void) addNeuron:(Neuron*)neuron;

@end
