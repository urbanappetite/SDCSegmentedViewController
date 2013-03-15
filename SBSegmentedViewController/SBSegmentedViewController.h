//
//  SBSegmentedViewController.h
//  SBSegmentedViewController
//
//  Created by Scott Berrevoets on 3/15/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBSegmentedViewController : UIViewController

@property (nonatomic, readonly, strong) UISegmentedControl *segmentedControl;

// NSArray of UIViewController subclasses
- (id)initWithViewControllers:(NSArray *)viewControllers;

@end
