//
//  MMBalloon.m
//  physics-2D-Verlet
//
//  Created by Adam Wulf on 3/26/15.
//  Copyright (c) 2015 Milestone made. All rights reserved.
//

#import "MMNeuron.h"
#import "Constants.h"
#import "MMStick.h"

@implementation MMNeuron{
    NSInteger color;
    MMStick* stick;
}

@synthesize center;
@synthesize radius;
@synthesize tail;

-(id) init{
    if(self = [super init]){
        color = rand() % 4;
        center = [[MMPoint alloc] init];
        center.attachable = NO;
        center.gravityModifier = -1;
        self.radius = kBalloonRadius;
        tail = [[MMPoint alloc] init];
        tail.x = radius;
        [tail nullVelocity];
        tail.gravityModifier = .1;

        stick = [MMStick stickWithP0:center andP1:tail];
    }
    return self;
}

+(MMNeuron*) balloonWithCGPoint:(CGPoint)p{
    MMNeuron* ret = [[MMNeuron alloc] init];
    ret.center.x = p.x;
    ret.center.y = p.y;
    [ret.center nullVelocity];
    ret.tail.x = p.x;
    ret.tail.y = p.y + ret.radius;
    [ret.tail nullVelocity];
    return ret;
}
-(void) setRadius:(CGFloat)_radius{
    radius = _radius;
    stick.length = _radius;

    CGFloat minG = -0.4;
    CGFloat maxG = -2;
    CGFloat percent = (radius - kBalloonMinRadius) / (kBalloonMaxRadius - kBalloonMinRadius);
    center.gravityModifier = minG + percent * (maxG - minG);
}

-(MMPoint*) p0{
    return center;
}

-(MMPoint*) p1{
    return tail;
}

-(void) tick{
    [stick tick];
}

#pragma mark - Update

-(void) updateWithGravity:(CGFloat)gravity andFriction:(CGFloat)friction{
    [center updateWithGravity:-gravity andFriction:friction];
}


-(void) render{
//    [center render];
    UIBezierPath* balloon = [UIBezierPath bezierPathWithArcCenter:self.center.asCGPoint
                                                       radius:radius
                                                   startAngle:0
                                                     endAngle:2*M_PI
                                                    clockwise:YES];
    
    if(color == 0){
        [[UIColor colorWithRed:180/255.0 green:0 blue:0 alpha:1] setFill];
    }else if(color == 1){
        [[UIColor colorWithRed:0 green:180/255.0 blue:0 alpha:1] setFill];
    }else if(color == 2){
        [[UIColor colorWithRed:0 green:0 blue:180/255.0 alpha:1] setFill];
    }else if(color == 3){
        [[UIColor colorWithRed:180/255.0 green:180/255.0 blue:.2 alpha:1] setFill];
    }
    [balloon stroke];
}

-(BOOL) replacePoint:(MMPoint*)p withPoint:(MMPoint*)newP{
    if([stick replacePoint:p withPoint:newP]){
        if(p == center){
            center = newP;
            center.attachable = NO;
            newP.gravityModifier = center.gravityModifier;
        }
        if(p == tail){
            tail = newP;
            newP.gravityModifier = tail.gravityModifier;
        }
        return YES;
    }
    return NO;
}

-(CGFloat) distanceFromPoint:(CGPoint)point{
    CGFloat dst = [center distanceFromPoint:point];
    return dst;
}

-(void) constrainCollisionsWith:(NSArray*)balloons{
    // make sure the balloon isn't hitting other balloons
    for(MMNeuron* otherB in balloons) {
        if([otherB isKindOfClass:[MMNeuron class]]){
            if(otherB != self){
                CGFloat dist = [otherB.center distanceFromPoint:self.center.asCGPoint];
                CGFloat movement = (otherB.radius + self.radius) - dist;
                if(movement > 0){
                    // collision!
                    
                    // fix their offset to be outside their
                    // combined radius
                    CGPoint distToMove = [otherB.center differenceFrom:self.center];
                    distToMove.x = (dist != 0) ? distToMove.x / dist : dist;
                    distToMove.y = (dist != 0) ? distToMove.y / dist : dist;
                    distToMove.x *= movement;
                    distToMove.y *= movement;
                    
                    self.center.x -= distToMove.x / 2;
                    self.center.y -= distToMove.y / 2;
                    otherB.center.x += distToMove.x / 2;
                    otherB.center.y += distToMove.y / 2;
                }
            }
        }
    }
}

-(void) constrain{
    [stick constrain];
}

-(MMPhysicsObject*) cloneObject{
    return [MMNeuron balloonWithCGPoint:center.asCGPoint];
}

-(void) translateBy:(CGPoint)trans{
    [stick translateBy:trans];
}

-(void) rotateBy:(CGFloat)rads{
    [stick rotateBy:rads];
}

-(NSArray*) allPoints{
    return @[center, tail];
}

#pragma mark - NSCoding

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:center forKey:@"center"];
    [aCoder encodeObject:tail forKey:@"tail"];
    [aCoder encodeObject:[NSNumber numberWithFloat:radius] forKey:@"radius"];
    [aCoder encodeObject:[NSNumber numberWithInteger:color] forKey:@"color"];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    if(self = [self init]){
        [self replacePoint:center withPoint:[aDecoder decodeObjectForKey:@"center"]];
        [self replacePoint:tail withPoint:[aDecoder decodeObjectForKey:@"tail"]];
        color = [[aDecoder decodeObjectForKey:@"color"] integerValue];
        radius = [[aDecoder decodeObjectForKey:@"radius"] floatValue];
        stick.length = radius;
    }
    return self;
}

@end
