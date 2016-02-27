//
//  HomeViewController.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 11/9/15.
//  Copyright © 2015 Ninan Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeViewControllerDelegate <NSObject>

@required
-(void) switchRootView;

@end

@interface HomeViewController : UIViewController

@property(nonatomic, weak) id<HomeViewControllerDelegate> delegate;

@end
