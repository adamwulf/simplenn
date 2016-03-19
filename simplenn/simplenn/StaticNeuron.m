//
//  StaticNeuron.m
//  simplenn
//
//  Created by Adam Wulf on 3/14/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import "StaticNeuron.h"

@implementation StaticNeuron

@synthesize value;

-(instancetype) initWithName:(NSString*)name andValue:(CGFloat)val{
    if(self = [super initWithName:name]){
        value = val;
    }
    return self;
}

-(CGFloat)latestOutput{
    return value;
}

#pragma mark - NSCoding

-(instancetype) initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        value = [aDecoder decodeFloatForKey:@"value"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:value forKey:@"value"];
}

@end
