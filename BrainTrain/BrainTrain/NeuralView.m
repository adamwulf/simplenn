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
    NSArray* positions;

    CGPoint gestureStartLocation;
    NSInteger heldNeuronIndex;
}

@synthesize inputs;
@synthesize neurons;
@synthesize outputs;

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
    inputs = @[];
    outputs = @[];
    neurons = @[];
    positions = @[];

    self.clearsContextBeforeDrawing = YES;

    InstantPanGestureRecognizer* pan = [[InstantPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:pan];

    UITapGestureRecognizer* selectItemGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:selectItemGesture];
}

#pragma mark - Gestures

-(void) tapGesture:(UITapGestureRecognizer*)tapGesture{
    for (int i=0; i<[neurons count]; i++) {
        if([NeuralView distance:[positions[i] CGPointValue] and:[tapGesture locationInView:self]] < 20){
            NSLog(@"tapped %@", neurons[i]);
            return;
        }
    }

    __block CGFloat minDist = 10;
    __block Neuron* mainNeuron;
    __block Neuron* inputNeuron;
    [self enumerateWeights:^(Neuron *n1, Neuron *n2, CGFloat w) {
        CGFloat dist = [self distanceFromPoint:[tapGesture locationInView:self] between:[self locationForNeuron:n1] and:[self locationForNeuron:n2]];
        if(dist < minDist){
            minDist = dist;
            mainNeuron = n1;
            inputNeuron = n2;
        }
    }];

    NSLog(@"tapped weight between %@ and %@", mainNeuron, inputNeuron);
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

#pragma mark - Public Methods

-(void) addNeuron:(Neuron*)neuron type:(NeuronType)type{
    neurons = [neurons arrayByAddingObject:neuron];
    CGPoint location = CGPointMake(rand() % (int)self.bounds.size.width, rand() % (int)self.bounds.size.width);
    positions = [positions arrayByAddingObject:[NSValue valueWithCGPoint:location]];

    if(type == NeuronInput){
        inputs = [inputs arrayByAddingObject:neuron];
    }else if(type == NeuronOutput){
        outputs = [outputs arrayByAddingObject:neuron];
    }
}

-(void) resetRandomWeight{
    int foo = rand() % [neurons count];

    Neuron* neuronToReset = neurons[foo];
    if([neuronToReset.inputs count]){
        int foo2 = rand() % (int)[[neurons[foo] inputs] count];
        [neuronToReset updateWeight:(rand() % 100) / 1000.0 forInputNeuron:neuronToReset.inputs[foo2]];
    }
}

-(NSDictionary*) asDictionary{
    return @{ @"inputs" : inputs, @"neurons" : neurons, @"outputs" : outputs, @"positions" : positions};
}

-(void) loadDictionary:(NSDictionary*)data{
    inputs = data[@"inputs"];
    neurons = data[@"neurons"];
    outputs = data[@"outputs"];
    positions = data[@"positions"];

    NSAssert(neurons && positions, @"data loaded ok");
}

#pragma mark - Rendering


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    [self enumerateNeurons:^(Neuron *neuron, CGPoint loc) {

        CGFloat radius = 20;

        UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:loc radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];
        path.lineWidth = 1;
        [path stroke];

        NSDictionary* attrs = @{ NSFontAttributeName : [UIFont systemFontOfSize:10] };
        CGSize nameSize = [[neuron name] sizeWithAttributes:attrs];
        CGPoint nameLoc = CGPointMake(loc.x - nameSize.width / 2, loc.y - nameSize.height / 2);
        [[neuron name] drawAtPoint:nameLoc withAttributes:attrs];


        for (Neuron* input in neuron.inputs) {
            CGPoint loc2 = [self locationForNeuron:input];
            MMVector* vec = [MMVector vectorWithPoint:loc andPoint:loc2];
            vec = [vec normal];

            CGPoint adjustedLoc = [vec pointFromPoint:loc distance:radius];
            loc2 = [vec pointFromPoint:loc2 distance:-radius];

            CGFloat weight = [neuron weightForInputNeuron:input];
            UIBezierPath* line = [UIBezierPath bezierPath];
            [line moveToPoint:adjustedLoc];
            [line addLineToPoint:loc2];
            line.lineWidth = ABS(weight * 5);
            [line stroke];
        }
    }];

}


#pragma mark - Neural Net Helpers

// will iterate over every weight
-(void) enumerateWeights:(void(^)(Neuron* n1, Neuron* n2, CGFloat w))iterationBlock{
    for (Neuron* n1 in neurons) {
        for (Neuron* n2 in n1.inputs) {
            iterationBlock(n1, n2, [n1 weightForInputNeuron:n2]);
        }
    }
}

// will iterate over every weight
-(void) enumerateNeurons:(void(^)(Neuron* neuron, CGPoint loc))iterationBlock{
    for (int i=0; i<[neurons count]; i++) {
        iterationBlock(neurons[i], [positions[i] CGPointValue]);
    }
}

-(CGPoint) locationForNeuron:(Neuron*)neuron{
    for (int i=0; i<[neurons count]; i++) {
        if(neurons[i] == neuron){
            return [positions[i] CGPointValue];
        }
    }
    return CGPointZero;
}

#pragma mark - Geometry Helpers

// return the distance from the input point
// to this line segment of p0 -> p1
-(CGFloat) distanceFromPoint:(CGPoint)point between:(CGPoint)p0 and:(CGPoint)p1{
    CGPoint pointOnLine = NearestPointOnLine(point, p0, p1);

    if((p0.x <= pointOnLine.x && pointOnLine.x <= p1.x) ||
       (p0.x >= pointOnLine.x && pointOnLine.x >= p1.x)){
        // it's X coordinate is between p0 and p1
        if((p0.y <= pointOnLine.y && pointOnLine.y <= p1.y) ||
           (p0.y >= pointOnLine.y && pointOnLine.y >= p1.y)){
            // it's Y coordinates are also between p0 and p1
            return [NeuralView distance:point and:pointOnLine];
        }
    }
    // found a point outside the line segment
    return MIN([NeuralView distance:point and:p0], [NeuralView distance:point and:p1]);
}

+(CGFloat) distance:(CGPoint)p0 and:(CGPoint)p1{
    CGFloat dx = p1.x - p0.x,
    dy = p1.y - p0.y;
    return sqrtf(dx * dx + dy * dy);
}




/// return the distance of <inPoint> from a line segment drawn from a to b.

CGPoint		NearestPointOnLine( const CGPoint inPoint, const CGPoint a, const CGPoint b )
{
    CGFloat mag = hypotf(( b.x - a.x ), ( b.y - a.y ));

    if( mag > 0.0 )
    {
        CGFloat u = ((( inPoint.x - a.x ) * ( b.x - a.x )) + (( inPoint.y - a.y ) * ( b.y - a.y ))) / ( mag * mag );

        if( u <= 0.0 )
            return a;
        else if ( u >= 1.0 )
            return b;
        else
        {
            CGPoint cp;

            cp.x = a.x + u * ( b.x - a.x );
            cp.y = a.y + u * ( b.y - a.y );

            return cp;
        }
    }
    else
        return a;
}






@end
