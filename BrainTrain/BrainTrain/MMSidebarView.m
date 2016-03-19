//
//  MMSidebarView.m
//  BrainTrain
//
//  Created by Adam Wulf on 3/18/16.
//  Copyright © 2016 Milestone Made. All rights reserved.
//

#import "MMSidebarView.h"

@implementation MMSidebarView

@synthesize delegate;

-(void) awakeFromNib{
    [super awakeFromNib];
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 1;

    UISwipeGestureRecognizer* closeSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToClose:)];
    closeSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:closeSwipeGesture];
    
    UIView* bitsOfWhite = [[UIView alloc] initWithFrame:self.bounds];
    bitsOfWhite.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *beView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    beView.frame = self.bounds;
    [beView.contentView addSubview:bitsOfWhite];
    [self insertSubview:beView atIndex:0];



    UIButton* randomWeightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [randomWeightButton setTitle:@"reset random weight" forState:UIControlStateNormal];
    [randomWeightButton addTarget:self action:@selector(resetRandomWeight) forControlEvents:UIControlEventTouchUpInside];
    [randomWeightButton sizeToFit];
    [self addSubview:randomWeightButton];
    [randomWeightButton setCenter:CGPointMake(self.bounds.size.width / 2, 40)];

    UIButton* saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [saveButton sizeToFit];
    [self addSubview:saveButton];
    [saveButton setCenter:CGPointMake(self.bounds.size.width / 2, 140)];

    UIButton* loadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loadButton setTitle:@"Load" forState:UIControlStateNormal];
    [loadButton addTarget:self action:@selector(load) forControlEvents:UIControlEventTouchUpInside];
    [loadButton sizeToFit];
    [self addSubview:loadButton];
    [loadButton setCenter:CGPointMake(self.bounds.size.width / 2, 240)];

}

#pragma mark - Actions

-(void) swipeToClose:(UISwipeGestureRecognizer*)swipeGesture{
    [self.delegate sidebarShouldClose];
}

-(void) resetRandomWeight{
    [self.delegate resetRandomWeight];
}

#pragma mark - Save and Load

-(void) save{
    [self.delegate save];
}

-(void) load{
    [self.delegate load];
}

@end
