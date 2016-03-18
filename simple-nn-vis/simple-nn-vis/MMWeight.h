//
//  MMWeight.h
//  simple-nn-vis
//
//  Created by Adam Wulf on 3/18/16.
//  Copyright © 2016 Milestone made. All rights reserved.
//

#import "MMStick.h"

@interface MMWeight : MMStick

+(MMStick*) weightWithP0:(MMPoint*)p0 andP1:(MMPoint*)p1;

@end
