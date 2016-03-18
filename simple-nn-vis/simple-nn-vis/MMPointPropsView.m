//
//  MMPointPropsView.m
//  physics-2D-Verlet
//
//  Created by Adam Wulf on 3/24/15.
//  Copyright (c) 2015 Milestone made. All rights reserved.
//

#import "MMPointPropsView.h"
#import "MMPoint.h"
#import "MMStick.h"

@implementation MMPointPropsView{
    MMPoint* selectedPoint;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){

    }
    return self;
}

-(void) showPointProperties:(MMPoint*)point{
    self.hidden = !point;
    selectedPoint = point;
}



@end
