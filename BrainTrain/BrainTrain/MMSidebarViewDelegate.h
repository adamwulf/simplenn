//
//  MMSidebarViewDelegate.h
//  BrainTrain
//
//  Created by Adam Wulf on 3/19/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMSidebarViewDelegate <NSObject>

-(void)sidebarShouldClose;

-(void) resetRandomWeight;

-(void) save;

-(void) load;

-(void) clearWeight;

@end
