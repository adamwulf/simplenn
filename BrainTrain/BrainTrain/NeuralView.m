//
//  NeuralView.m
//  BrainTrain
//
//  Created by Adam Wulf on 3/17/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import "NeuralView.h"

@implementation NeuralView{
    NSArray* neurons;
    NSArray* positions;
}

-(instancetype) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self initCommon];
    }
    return self;
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self initCommon];
    }
    return self;
}

-(void) initCommon{
    neurons = @[];
    positions = @[];

    self.clearsContextBeforeDrawing = YES;
}

-(void) addNeuron:(Neuron*)neuron{
    neurons = [neurons arrayByAddingObject:neuron];
    CGPoint location = CGPointMake(rand() % (int)self.bounds.size.width, rand() % (int)self.bounds.size.width);
    positions = [positions arrayByAddingObject:[NSValue valueWithCGPoint:location]];
}

-(CGPoint) locationForNeuron:(Neuron*)neuron{
    for (int i=0; i<[neurons count]; i++) {
        if(neurons[i] == neuron){
            return [positions[i] CGPointValue];
        }
    }
    return CGPointZero;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    for (int i=0; i<[neurons count]; i++) {
        Neuron* neuron = neurons[i];
        CGPoint loc = [positions[i] CGPointValue];

        UIBezierPath* path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(loc.x - 20, loc.y - 20, 40, 40)];
        path.lineWidth = 1;
        [path stroke];

        NSDictionary* attrs = @{ NSFontAttributeName : [UIFont systemFontOfSize:10] };
        CGSize nameSize = [[neuron name] sizeWithAttributes:attrs];
        CGPoint nameLoc = CGPointMake(loc.x - nameSize.width / 2, loc.y - nameSize.height / 2);
        [[neuron name] drawAtPoint:nameLoc withAttributes:attrs];


        for (Neuron* input in neuron.inputs) {
            CGFloat weight = [neuron weightForInputNeuron:input];
            UIBezierPath* line = [UIBezierPath bezierPath];
            [line moveToPoint:loc];
            [line addLineToPoint:[self locationForNeuron:input]];
            line.lineWidth = ABS(weight * 5);
            [line stroke];
        }

    }
}



@end
