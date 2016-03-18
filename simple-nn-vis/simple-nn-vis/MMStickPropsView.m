//
//  MMStickPropsView.m
//  spareparts
//
//  Created by Adam Wulf on 4/1/15.
//  Copyright (c) 2015 Milestone made. All rights reserved.
//

#import "MMStickPropsView.h"
#import "Constants.h"
#import "MMNeuron.h"

@implementation MMStickPropsView{
    MMPhysicsObject* selectedStick;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){


    }
    return self;
}

-(void) showObjectProperties:(MMPhysicsObject*)object{
    selectedStick = object;
    self.hidden = !object;
    if([object isKindOfClass:[MMNeuron class]]){
        MMNeuron* b = (MMNeuron*)object;
    }else{
        MMStick* stick = (MMStick*)object;
    }
}

@end
