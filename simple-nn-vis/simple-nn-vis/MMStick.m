//
//  MMStick.m
//  physics-2D-Verlet
//
//  Created by Adam Wulf on 3/23/15.
//  Copyright (c) 2015 Milestone made. All rights reserved.
//

#import "MMStick.h"
#import "Constants.h"


@implementation MMStick

@synthesize length;

-(id) init{
    if(self = [super init]){
        p0 = [MMPoint point];
        p1 = [MMPoint point];
        length = [self calcLen];
    }
    return self;
}

-(id) initWithP0:(MMPoint*)_p0 andP1:(MMPoint*)_p1{
    if(self = [super init]){
        p0 = _p0;
        p1 = _p1;
        length = [self calcLen];
        int stickType = rand() % 5;
        NSString* imageName = [NSString stringWithFormat:@"board-%d.png", stickType];
        image = [UIImage imageNamed:imageName];
    }
    return self;
}

+(MMStick*) stickWithP0:(MMPoint*)p0 andP1:(MMPoint*)p1{
    return [[MMStick alloc] initWithP0:p0 andP1:p1];
}

-(CGFloat) calcLen{
    CGFloat dx = p1.x - p0.x,
    dy = p1.y - p0.y;
    return sqrtf(dx * dx + dy * dy);
}

-(void) setLength:(CGFloat)_length{
    length = _length;
    [self constrain];
}

-(void) tick{
    // noop
}

-(void) rotateBy:(CGFloat)rads{
    CGPoint c = CGPointMake((self.p0.x + self.p1.x)/2,
                            (self.p0.y + self.p1.y)/2);
    
    CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformRotate(CGAffineTransformMakeTranslation(c.x, c.y), rads), -c.x, -c.y);
    CGPoint cgp0 = CGPointApplyAffineTransform(self.p0.asCGPoint, transform);
    CGPoint cgp1 = CGPointApplyAffineTransform(self.p1.asCGPoint, transform);
    
    self.p0.x = cgp0.x;
    self.p0.y = cgp0.y;
    self.p1.x = cgp1.x;
    self.p1.y = cgp1.y;
}

-(void) translateBy:(CGPoint)trans{
    self.p0.x = self.p0.x + trans.x;
    self.p0.y = self.p0.y + trans.y;
    self.p1.x = self.p1.x + trans.x;
    self.p1.y = self.p1.y + trans.y;
}


-(void) constrain{
    CGFloat dx = self.p1.x - self.p0.x;
    CGFloat dy = self.p1.y - self.p0.y;
    CGFloat distance = sqrtf(dx * dx + dy * dy);
    CGFloat difference = self.length - distance;
    CGFloat percent = difference / distance / 2;
    if(isnan(percent) || !isfinite(percent)){
        percent = 0;
    }
    CGFloat offsetX = dx * percent;
    CGFloat offsetY = dy * percent;
    
    self.p0.x -= offsetX;
    self.p0.y -= offsetY;

    self.p1.x += offsetX;
    self.p1.y += offsetY;
}

-(CGFloat) stress{
    // calculate stress
    CGFloat idealLenth = [self length];
    CGFloat currLength = [self calcLen];
    CGFloat percDiff = ABS(currLength - idealLenth) / [self length];
    
    // .0 => blue
    // .1 => red
    return MIN(.1, percDiff) * 10;
}

-(void) render{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // translate
    CGContextTranslateCTM(context, self.p0.x, self.p0.y);
    // rotate
    CGFloat angle = atan2f(self.p1.x - self.p0.x, self.p1.y - self.p0.y);
    CGContextRotateCTM(context, -angle + M_PI/2);
    
    [self renderAtZeroZero];
    
    CGContextRestoreGState(context);
}


-(void) renderAtZeroZero{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // draw our board image

    [[UIColor blackColor] setStroke];

    UIBezierPath* stickLine = [UIBezierPath bezierPath];
    [stickLine moveToPoint:CGPointZero];
    [stickLine addLineToPoint:CGPointMake([self calcLen], 0)];
    stickLine.lineWidth = 2;
    [stickLine stroke];

    // render our nails / screws
    [p0 renderAtZeroZero];
    CGContextTranslateCTM(context, [self calcLen], 0);
    
    [p1 renderAtZeroZero];
    CGContextRestoreGState(context);
}


#pragma mark - create stick that matches our type

-(BOOL) replacePoint:(MMPoint*)p withPoint:(MMPoint*)newP{
    if((p == p0 && newP == p1) ||
       (p == p1 && newP == p0)){
        return NO;
    }
    if(p == p0){
        p0 = newP;
    }
    if(p == p1){
        p1 = newP;
    }
    return YES;
}

// return the distance from the input point
// to this line segment of p0 -> p1
-(CGFloat) distanceFromPoint:(CGPoint)point{
    CGPoint pointOnLine = NearestPointOnLine(point, self.p0.asCGPoint, self.p1.asCGPoint);

    if((self.p0.x <= pointOnLine.x && pointOnLine.x <= self.p1.x) ||
       (self.p0.x >= pointOnLine.x && pointOnLine.x >= self.p1.x)){
        // it's X coordinate is between p0 and p1
        if((self.p0.y <= pointOnLine.y && pointOnLine.y <= self.p1.y) ||
           (self.p0.y >= pointOnLine.y && pointOnLine.y >= self.p1.y)){
            // it's Y coordinates are also between p0 and p1
            return [MMPoint distance:point and:pointOnLine];
        }
    }
    // found a point outside the line segment
    return MIN([MMPoint distance:point and:self.p0.asCGPoint], [MMPoint distance:point and:self.p1.asCGPoint]);
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

-(MMPhysicsObject*) cloneObject{
    return [MMStick stickWithP0:[MMPoint pointWithCGPoint:p0.asCGPoint]
                          andP1:[MMPoint pointWithCGPoint:p1.asCGPoint]];
}

-(NSArray*) allPoints{
    return @[p0, p1];
}

#pragma mark - NSCoding

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:p0 forKey:@"p0"];
    [aCoder encodeObject:p1 forKey:@"p1"];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    MMPoint* _p0 = [aDecoder decodeObjectForKey:@"p0"];
    MMPoint* _p1 = [aDecoder decodeObjectForKey:@"p1"];
    if(self = [self initWithP0:_p0 andP1:_p1]){
        // noop
    }
    return self;
}

@end
