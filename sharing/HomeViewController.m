//
//  HomeViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 11/9/15.
//  Copyright © 2015 Ninan Thomas. All rights reserved.
//

#import "HomeViewController.h"


@implementation HomeViewController

@synthesize delegate;

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    //self.hidesBottomBarWhenPushed = YES;
    [delegate switchRootView];
    
}

- (void)viewDidLoad
{
  // [delegate switchRootView];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

@end
