//
//  MMPhysicsView.m
//  physics-2D-Verlet
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone made. All rights reserved.
//

#import "MMPhysicsView.h"
#import "InstantPanGestureRecognizer.h"
#import "MMPointPropsView.h"
#import "MMStickPropsView.h"
#import "MMPhysicsObject.h"
#import "MMPoint.h"
#import "MMStick.h"
#import "MMNeuron.h"
#import "Constants.h"
#import "MMPhysicsViewController.h"
#import "SaveLoadManager.h"
#import "PropertiesViewDelegate.h"
#import "CustomRotationGesture.h"

#define kMaxStress 0.5

@interface MMPhysicsView ()<UIGestureRecognizerDelegate,PropertiesViewDelegate>

@end

@implementation MMPhysicsView{
    CGFloat bounce;
    CGFloat gravity;
    CGFloat friction;
    
    // state
    NSMutableArray* points;
    NSMutableArray* sticks;

    // stuff for the move gesture
    MMPhysicsObject* grabbedStick;
    CGPoint grabbedStickOffsetP0;
    CGPoint grabbedStickOffsetP1;
    MMPoint* grabbedPoint;
    
    // all of the gestures
    UITapGestureRecognizer* selectGesture;
    UIPanGestureRecognizer* grabPointGesture;
    
    CGPoint lastTranslationValue;
    CGFloat lastRotationValue;
    CustomRotationGesture* rotateGesture;
    UIPanGestureRecognizer* twoFingerPanGesture;
    
    // the stick that's currently being made
    MMPhysicsObject* currentEditedStick;

    MMPointPropsView* pointPropertiesView;
    MMStickPropsView* stickPropertiesView;
    MMPoint* selectedPoint;
    MMPhysicsObject* selectedStick;
    
    NSMutableSet* processedPoints;
    
    BOOL isActivelyEditingProperties;
}

@synthesize controller;
@synthesize staticObjects;
@synthesize delegate;
@synthesize points;
@synthesize sticks;

-(id) initWithFrame:(CGRect)frame andDelegate:(NSObject<PhysicsViewDelegate>*)_delegate{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.delegate = _delegate;
        
        bounce = 0.9;
        gravity = 0.5;
        friction = 0.999;
        
        processedPoints = [NSMutableSet set];
        
        points = [NSMutableArray array];
        sticks = [NSMutableArray array];
        
        pointPropertiesView = [[MMPointPropsView alloc] initWithFrame:CGRectMake(20, 20, 200, 250)];
        pointPropertiesView.delegate = self;
        [self addSubview:pointPropertiesView];
        
        stickPropertiesView = [[MMStickPropsView alloc] initWithFrame:CGRectMake(20, 20, 200, 250)];
        stickPropertiesView.delegate = self;
        [self addSubview:stickPropertiesView];
        
        [self initializeData];
        
        rotateGesture = [[CustomRotationGesture alloc] initWithTarget:self action:@selector(rotateGesture:)];
        [self addGestureRecognizer:rotateGesture];
        
        twoFingerPanGesture = [[InstantPanGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerPanGesture:)];
        twoFingerPanGesture.minimumNumberOfTouches = 2;
        twoFingerPanGesture.maximumNumberOfTouches = 2;
        [self addGestureRecognizer:twoFingerPanGesture];
        
        selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPointGesture:)];
        selectGesture.delegate = self;
        selectGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:selectGesture];
        
        grabPointGesture = [[InstantPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePointGesture:)];
        grabPointGesture.delegate = self;
        grabPointGesture.minimumNumberOfTouches = 1;
        grabPointGesture.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:grabPointGesture];
        
        
        [rotateGesture requireGestureRecognizerToFail:grabPointGesture];
        [twoFingerPanGesture requireGestureRecognizerToFail:grabPointGesture];
        
       
        // initialize default objects in the sidebar
        staticObjects = [NSMutableArray array];
        
        [self setNeedsDisplay];
    }
    return self;
}

#pragma mark - Gesture

-(void) twoFingerPanGesture:(InstantPanGestureRecognizer*)panGesture{
    if(panGesture.state == UIGestureRecognizerStateBegan){
        if(panGesture.numberOfTouches != 2){
            // what
            NSLog(@"asdfasdf");
        }
        // reset our last to 0
        lastTranslationValue = CGPointZero;
    }else{
        // delta == current - last;
        CGPoint currTrans = [panGesture translationInView:self];
        CGPoint deltaTrans;
        deltaTrans.x = currTrans.x - lastTranslationValue.x;
        deltaTrans.y = currTrans.y - lastTranslationValue.y;
        [selectedStick translateBy:deltaTrans];
        lastTranslationValue = currTrans;
    }
}

-(void) rotateGesture:(UIRotationGestureRecognizer*)rotGesture{
    if(rotGesture.state == UIGestureRecognizerStateBegan){
        // reset our last to 0
        lastRotationValue = 0;
    }else{
        // delta == current - last;
        CGFloat deltaRot = rotGesture.rotation - lastRotationValue;
        [selectedStick rotateBy:deltaRot*2];
        lastRotationValue = rotGesture.rotation;
    }
    [self setNeedsDisplay];
}


-(void) tapPointGesture:(UITapGestureRecognizer*)tapGesture{
    CGPoint currLoc = [tapGesture locationInView:self];
    if(tapGesture.state == UIGestureRecognizerStateRecognized){
        selectedPoint = [self getPointNear:currLoc];
        selectedStick = nil;
        if(!selectedPoint){
            selectedStick = [self getStickNear:currLoc];
        }
        [pointPropertiesView showPointProperties:selectedPoint];
        [stickPropertiesView showObjectProperties:selectedStick];
    }
}

-(void) movePointGesture:(InstantPanGestureRecognizer*)panGesture{
    if(panGesture.state == UIGestureRecognizerStateBegan){
        CGPoint currLoc = panGesture.initialLocationInWindow;
        // find the point to grab
        MMPhysicsObject* stick = [self getSidebarObject:currLoc];
        if(stick){
            selectedPoint = nil;
            selectedStick = stick;
            [pointPropertiesView showPointProperties:selectedPoint];
            [stickPropertiesView showObjectProperties:selectedStick];
            // we just created a new object
            [points addObjectsFromArray:[stick allPoints]];
            if([stick isKindOfClass:[MMNeuron class]]){
                [sticks addObject:stick];
                grabbedPoint = [((MMNeuron*)stick) center];
            }else{
                [sticks addObject:stick];
                grabbedStick = stick;
                grabbedStickOffsetP0 = CGPointMake(currLoc.x - grabbedStick.p0.x,
                                                   currLoc.y - grabbedStick.p0.y);
                grabbedStickOffsetP1 = CGPointMake(currLoc.x - grabbedStick.p1.x,
                                                   currLoc.y - grabbedStick.p1.y);
            }
        }else{
            grabbedPoint = [self getPointNear:currLoc];
            if(!grabbedPoint){
                grabbedStick = [self getStickNear:currLoc];
                NSLog(@"got stick %@", [grabbedStick class]);
                grabbedStickOffsetP0 = CGPointMake(currLoc.x - grabbedStick.p0.x,
                                                   currLoc.y - grabbedStick.p0.y);
                grabbedStickOffsetP1 = CGPointMake(currLoc.x - grabbedStick.p1.x,
                                                   currLoc.y - grabbedStick.p1.y);
            }else{
                NSLog(@"got point %@", [grabbedPoint class]);
            }
            selectedPoint = grabbedPoint;
            selectedStick = grabbedStick;
            [pointPropertiesView showPointProperties:selectedPoint];
            [stickPropertiesView showObjectProperties:selectedStick];

        }
    }else if(panGesture.state == UIGestureRecognizerStateEnded){
        for (MMPoint* pointToSnap in (grabbedPoint ? @[grabbedPoint] : [grabbedStick allPoints])) {
            MMPoint* pointToReplace = [[points filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return evaluatedObject != pointToSnap && [evaluatedObject distanceFromPoint:pointToSnap.asCGPoint] < 30;
            }]] firstObject];
            BOOL didReplaceAllPoints = YES;
            if(pointToReplace && pointToReplace.attachable && pointToSnap.attachable){
                for(int i=0;i<[sticks count];i++){
                    MMPhysicsObject* stick = [sticks objectAtIndex:i];
                    didReplaceAllPoints = didReplaceAllPoints && [stick replacePoint:pointToReplace withPoint:pointToSnap];
                }
                if(didReplaceAllPoints){
                    [points removeObject:pointToReplace];
                }
                if(pointToReplace == selectedPoint){
                    selectedPoint = pointToSnap;
                    [pointPropertiesView showPointProperties:pointToSnap];
                }
            }
        }
        grabbedPoint = nil;
        grabbedStick = nil;
    }

    [self setNeedsDisplay];
}


#pragma mark - Data

-(void) initializeData{
    [self.delegate initializePhysicsDataIntoPoints:points
                                         andSticks:sticks];
}

#pragma mark - Animation Loop

-(void) drawRect:(CGRect)rect{
    // draw
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // clear
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, rect);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    
    // render sidebar objects
    for (MMPhysicsObject* stick in staticObjects){
        [stick render];
    }
    

    // update rotate
    
    [processedPoints removeAllObjects];
    // constrain everything
    for(int i = 0; i < 5; i++) {
        [self enforceGesture];
        [self constrainSticks];
        [self constrainBalloons];
        [self constrainPoints];
    }
    
    // render everything
    [self renderSticks];
    
    if(selectedStick){
        [selectedStick renderWithHighlight];
    }
    if(selectedPoint){
        [selectedPoint renderWithHighlight];
    }
    
    // render edit
    [currentEditedStick render];
    
    CGContextRestoreGState(context);
}


#pragma mark - Update Methods

-(void) tickMachines{
    for(MMPhysicsObject* stick in sticks){
        [stick tick];
    }
}

-(void) enforceGesture{
    if(grabbedPoint){
        if(grabPointGesture.state == UIGestureRecognizerStateBegan ||
           grabPointGesture.state == UIGestureRecognizerStateChanged){
            grabbedPoint.x = [grabPointGesture locationInView:self].x;
            grabbedPoint.y = [grabPointGesture locationInView:self].y;
        }
        for (MMPoint* p in points) {
            [p nullVelocity];
        }
    }else if(grabbedStick){
        if(grabPointGesture.state == UIGestureRecognizerStateBegan ||
           grabPointGesture.state == UIGestureRecognizerStateChanged){
            grabbedStick.p0.x = [grabPointGesture locationInView:self].x - grabbedStickOffsetP0.x;
            grabbedStick.p0.y = [grabPointGesture locationInView:self].y - grabbedStickOffsetP0.y;
            grabbedStick.p1.x = [grabPointGesture locationInView:self].x - grabbedStickOffsetP1.x;
            grabbedStick.p1.y = [grabPointGesture locationInView:self].y - grabbedStickOffsetP1.y;
        }
        for (MMPoint* p in points) {
            [p nullVelocity];
        }
    }
}

-(void) updatePoints{
    for(int i = 0; i < [points count]; i++) {
        MMPoint* p = [points objectAtIndex:i];
        [p updateWithGravity:gravity andFriction:friction];
    }
}

-(void) constrainSticks{
    for(int i = 0; i < [sticks count]; i++) {
        MMPhysicsObject* s = [sticks objectAtIndex:i];
        if(![s isKindOfClass:[MMNeuron class]]){
            [s constrain];
        }
    }
}

-(void) constrainBalloons{
    for(MMNeuron* b in sticks) {
        if([b isKindOfClass:[MMNeuron class]]){
            if(![processedPoints containsObject:b.center]){
                [processedPoints addObject:b.center];
                // make sure balloon is inside the box
                CGFloat vx = (b.center.x - b.center.oldx) * friction;
                CGFloat vy = (b.center.y - b.center.oldy) * friction;
                
                if(b.center.x > self.bounds.size.width - b.radius) {
                    b.center.x = self.bounds.size.width - b.radius;
                    b.center.oldx = b.center.x + vx * bounce;
                }
                else if(b.center.x < b.radius) {
                    b.center.x = b.radius;
                    b.center.oldx = b.center.x + vx * bounce;
                }
                if(b.center.y > self.bounds.size.height - b.radius) {
                    b.center.y = self.bounds.size.height - b.radius;
                    b.center.oldy = b.center.y + vy * bounce;
                }
                else if(b.center.y < b.radius) {
                    b.center.y = b.radius;
                    b.center.oldy = b.center.y + vy * bounce;
                }
                [b constrain];
                [b constrainCollisionsWith:sticks];
                [b constrain];
            }
        }
    }
}

-(void) constrainPoints{
    for(int i = 0; i < [points count]; i++) {
        MMPoint* p = [points objectAtIndex:i];
        if(![processedPoints containsObject:p]){
            [processedPoints addObject:p];
            CGFloat vx = (p.x - p.oldx) * friction;
            CGFloat vy = (p.y - p.oldy) * friction;
            
            // bounce off the edge of window
            if(p.x > self.bounds.size.width - kStickWidth/2) {
                p.x = self.bounds.size.width - kStickWidth/2;
                p.oldx = p.x + vx * bounce;
            }
            else if(p.x < kStickWidth/2) {
                p.x = kStickWidth/2;
                p.oldx = p.x + vx * bounce;
            }
            if(p.y > self.bounds.size.height - kStickWidth/2) {
                p.y = self.bounds.size.height - kStickWidth/2;
                p.oldy = p.y + vy * bounce;
            }
            else if(p.y < kStickWidth/2) {
                p.y = kStickWidth/2;
                p.oldy = p.y + vy * bounce;
            }
        }
    }
}

#pragma mark - Render

-(void) renderSticks{
    for(MMPhysicsObject* stick in sticks){
        [stick render];
    }
}

#pragma mark - Helper

-(MMPoint*) getPointNear:(CGPoint)point{
    MMPoint* ret = [[points sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 distanceFromPoint:point] < [obj2 distanceFromPoint:point] && [obj1 attachable] ? NSOrderedAscending : NSOrderedDescending;
    }] firstObject];
    if([ret distanceFromPoint:point] < 30 && ret.attachable){
        return ret;
    }
    return nil;
}

-(MMPhysicsObject*) getStickNear:(CGPoint)point{
    MMPhysicsObject* ret = [[sticks sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 distanceFromPoint:point] < [obj2 distanceFromPoint:point] ? NSOrderedAscending : NSOrderedDescending;
    }] firstObject];
    NSLog(@"closest stick is: %f", [ret distanceFromPoint:point]);
    if([ret distanceFromPoint:point] < 30){
        return ret;
    }
    return nil;
}

-(MMPhysicsObject*) getSidebarObject:(CGPoint)point{
    return [delegate getSidebarObject:point];
}

#pragma mark - LoadingDeviceViewDelegate

-(void) loadPoints:(NSArray *)_points andSticks:(NSArray *)_sticks{
    [points addObjectsFromArray:_points];
    [sticks addObjectsFromArray:_sticks];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([touch.view isKindOfClass:[UIControl class]] ||
       touch.view == pointPropertiesView ||
       touch.view == stickPropertiesView){
        return NO;
    }
    return YES;
}

#pragma mark - PropertiesViewDelegate

-(void) didStartEditingProperties{
    isActivelyEditingProperties = YES;
}

-(void) didStopEditingProperties{
    isActivelyEditingProperties = NO;
}

-(void) turnOffGestures{
    selectGesture.enabled = NO;
    grabPointGesture.enabled = NO;
}

-(void) hideSidebar{
    for(UIView* v in self.subviews){
        if([v isKindOfClass:[UIControl class]]){
            v.hidden = YES;
        }
    }
}

@end
