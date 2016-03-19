//
//  NeuralView.m
//  BrainTrain
//
//  Created by Adam Wulf on 3/17/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import "NeuralView.h"
#import "InstantPanGestureRecognizer.h"
#import "MMVector.h"

@implementation NeuralView{
    NSArray* neurons;
    NSArray* positions;

    CGPoint gestureStartLocation;
    NSInteger heldNeuronIndex;
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

    InstantPanGestureRecognizer* pan = [[InstantPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:pan];
}

-(void) panGesture:(InstantPanGestureRecognizer*)gesture{
    if(gesture.state == UIGestureRecognizerStateBegan){
        heldNeuronIndex = NSIntegerMax;
        CGFloat minDist = 100;
        CGPoint startLoc = [gesture locationInView:self];
        for (int i=0; i<[neurons count]; i++) {
            CGFloat dist = [NeuralView distance:[positions[i] CGPointValue] and:startLoc];
            if(dist < minDist){
                gestureStartLocation = [positions[i] CGPointValue];
                heldNeuronIndex = i;
                minDist = dist;
            }
        }
    }else if(gesture.state == UIGestureRecognizerStateChanged){
        CGPoint trans = [gesture translationInView:self];

        if(heldNeuronIndex != NSIntegerMax){
            CGPoint newLoc = gestureStartLocation;
            newLoc.x += trans.x;
            newLoc.y += trans.y;
            NSMutableArray* newPositions = [NSMutableArray arrayWithArray:positions];
            [newPositions replaceObjectAtIndex:heldNeuronIndex withObject:[NSValue valueWithCGPoint:newLoc]];
            positions = newPositions;
        }
    }

    [self setNeedsDisplay];
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

        CGFloat radius = 20;

        UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:loc radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];
        path.lineWidth = 1;
        [path stroke];

        NSDictionary* attrs = @{ NSFontAttributeName : [UIFont systemFontOfSize:10] };
        CGSize nameSize = [[neuron name] sizeWithAttributes:attrs];
        CGPoint nameLoc = CGPointMake(loc.x - nameSize.width / 2, loc.y - nameSize.height / 2);
        [[neuron name] drawAtPoint:nameLoc withAttributes:attrs];


        for (Neuron* input in neuron.inputs) {
            loc = [positions[i] CGPointValue];
            CGPoint loc2 = [self locationForNeuron:input];
            MMVector* vec = [MMVector vectorWithPoint:loc andPoint:loc2];
            vec = [vec normal];

            loc = [vec pointFromPoint:loc distance:radius];
            loc2 = [vec pointFromPoint:loc2 distance:-radius];

            CGFloat weight = [neuron weightForInputNeuron:input];
            UIBezierPath* line = [UIBezierPath bezierPath];
            [line moveToPoint:loc];
            [line addLineToPoint:loc2];
            line.lineWidth = ABS(weight * 5);
            [line stroke];
        }
    }
}



+(CGFloat) distance:(CGPoint)p0 and:(CGPoint)p1{
    CGFloat dx = p1.x - p0.x,
    dy = p1.y - p0.y;
    return sqrtf(dx * dx + dy * dy);
}

-(void) resetRandomWeight{
    int foo = rand() % [neurons count];

    Neuron* neuronToReset = neurons[foo];
    if([neuronToReset.inputs count]){
        int foo2 = rand() % (int)[[neurons[foo] inputs] count];
        [neuronToReset updateWeight:(rand() % 100) / 1000.0 forInputNeuron:neuronToReset.inputs[foo2]];
    }
}

@end
