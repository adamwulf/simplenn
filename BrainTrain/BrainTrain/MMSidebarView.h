//
//  MMSidebarView.h
//  BrainTrain
//
//  Created by Adam Wulf on 3/18/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSidebarViewDelegate.h"

@interface MMSidebarView : UIView

@property (nonatomic, weak) IBOutlet NSObject<MMSidebarViewDelegate>* delegate;

@end
