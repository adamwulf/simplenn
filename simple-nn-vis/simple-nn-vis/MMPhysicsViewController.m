//
//  ViewController.m
//  physics-2D-Verlet
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone made. All rights reserved.
//

#import "MMPhysicsViewController.h"
#import "MMPhysicsView.h"
#import "SidebarView.h"
#import "Constants.h"
#import "MMStick.h"
#import "MMWeight.h"
#import "MMNeuron.h"
#import "PhysicsViewDelegate.h"
#import "SidebarViewDelegate.h"
#import "LoadingDeviceView.h"
#import "LoadingDeviceViewDelegate.h"
#import "SaveLoadManager.h"

@interface MMPhysicsViewController ()<PhysicsViewDelegate,SidebarViewDelegate,LoadingDeviceViewDelegate>

@end

@implementation MMPhysicsViewController{
    MMPhysicsView* physicsView;
    SidebarView* sidebar;
    UIAlertAction *saveAction;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    physicsView = [[MMPhysicsView alloc] initWithFrame:self.view.bounds andDelegate:self];
    physicsView.controller = self;
    physicsView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:physicsView];

    sidebar = [[SidebarView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-kSidebarWidth, 0, kSidebarWidth, self.view.bounds.size.height)];
    sidebar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    sidebar.delegate = self;
    [self.view addSubview:sidebar];

    UIButton* toggleSidebar = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    toggleSidebar.center = CGPointMake(self.view.bounds.size.width - 60, 80);
    [toggleSidebar setTitle:@">>" forState:UIControlStateNormal];
    [toggleSidebar setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [toggleSidebar addTarget:self action:@selector(toggleSidebar:) forControlEvents:UIControlEventTouchUpInside];
    toggleSidebar.layer.borderColor = [UIColor blackColor].CGColor;
    toggleSidebar.layer.borderWidth = 1;
    toggleSidebar.layer.cornerRadius = 7;
    self.view.userInteractionEnabled = YES;
    [self.view addSubview:toggleSidebar];
}

-(void) toggleSidebar:(UIButton*)button{
    if(sidebar.frame.origin.x >= self.view.bounds.size.width){
        [button setTitle:@">>" forState:UIControlStateNormal];
        [UIView animateWithDuration:.3 animations:^{
            CGRect fr = sidebar.frame;
            fr.origin.x = self.view.bounds.size.width - kSidebarWidth;
            sidebar.frame = fr;
        }];
    }else{
        [button setTitle:@"<<" forState:UIControlStateNormal];
        [UIView animateWithDuration:.3 animations:^{
            CGRect fr = sidebar.frame;
            fr.origin.x = self.view.bounds.size.width;
            sidebar.frame = fr;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PhysicsViewDelegate

-(void) initializePhysicsDataIntoPoints:(NSMutableArray *)points
                              andSticks:(NSMutableArray *)sticks{
    [points addObject:[MMPoint pointWithX:300 andY:100]];
    [points addObject:[MMPoint pointWithX:400 andY:100]];
    [points addObject:[MMPoint pointWithX:400 andY:200]];
    [points addObject:[MMPoint pointWithX:300 andY:200]];

    [sticks addObject:[MMWeight weightWithP0:[points objectAtIndex:0]
                                       andP1:[points objectAtIndex:1]]];
    [sticks addObject:[MMWeight weightWithP0:[points objectAtIndex:1]
                                       andP1:[points objectAtIndex:2]]];
    [sticks addObject:[MMWeight weightWithP0:[points objectAtIndex:2]
                                       andP1:[points objectAtIndex:3]]];
    [sticks addObject:[MMWeight weightWithP0:[points objectAtIndex:3]
                                       andP1:[points objectAtIndex:0]]];
    [sticks addObject:[MMWeight weightWithP0:[points objectAtIndex:0]
                                       andP1:[points objectAtIndex:2]]];
    [sticks addObject:[MMWeight weightWithP0:[points objectAtIndex:1]
                                       andP1:[points objectAtIndex:3]]];
}


-(MMPhysicsObject*) getSidebarObject:(CGPoint)point{
    point = [sidebar convertPoint:point fromView:physicsView];
    MMPhysicsObject* ret = [[sidebar.physicsView.staticObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 distanceFromPoint:point] < [obj2 distanceFromPoint:point] ? NSOrderedAscending : NSOrderedDescending;
    }] firstObject];
    if([ret distanceFromPoint:point] < 30){
        // translate object back into the physics view
        // coordinate system.
        
        ret = [ret cloneObject];
        CGPoint translation = [sidebar convertPoint:CGPointZero toView:physicsView];
        [ret translateBy:translation];
        
        return ret;
    }
    return nil;
}


#pragma mark - SidebarViewDelegate

-(void) saveObjects{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Save!" message:@"Name your contraption!" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(alertTextFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:textField];
    }];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    saveAction = [UIAlertAction
                  actionWithTitle:@"Save"
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction *action)
                  {
                      [[NSNotificationCenter defaultCenter] removeObserver:self];
                      saveAction = nil;
                      
                      NSString* name = [[alert.textFields firstObject] text];
                      NSLog(@"Save action: %@", name);
                      
                      [[SaveLoadManager sharedInstance] savePoints:physicsView.points andSticks:physicsView.sticks forName:name];
                  }];
    saveAction.enabled = NO;
    [alert addAction:saveAction];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       [[NSNotificationCenter defaultCenter] removeObserver:self];
                                       saveAction = nil;
                                   }];
    [alert addAction:cancelAction];
}

-(void) loadObjects{
    LoadingDeviceView* loadingView = [[LoadingDeviceView alloc] initWithFrame:self.view.bounds];
    loadingView.delegate = self;
    [self.view addSubview:loadingView];
    [loadingView reloadData];
}

#pragma mark - LoadingDeviceViewDelegate


-(void) alertTextFieldDidChange:(NSNotification*)note{
    // did change
    if([[note.object text] length]){
        saveAction.enabled = YES;
    }else{
        saveAction.enabled = NO;
    }
}


-(void) loadDeviceNamed:(NSString*)name{
    NSDictionary* loadedInfo = [[SaveLoadManager sharedInstance] loadName:name];

    [physicsView loadPoints:[loadedInfo objectForKey:@"points"]
                  andSticks:[loadedInfo objectForKey:@"sticks"]];
}

-(void) cancelLoadingDevice{
    // noop
}

@end
