//
//  DemoViewController.m
//  SBSegmentedViewController
//
//  Created by Scott Berrevoets on 3/15/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "DemoViewController.h"
#import "SBSegmentedViewController.h"

@implementation DemoViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIViewController *vc1 = [[UIViewController alloc] init];
	vc1.title = @"Title 1";
	
	UIViewController *vc2 = [[UIViewController alloc] init];
	vc2.title = @"Title 2";
	
	UIViewController *vc3 = [[UIViewController alloc] init];
	vc3.title = @"Title 3";
	
	NSArray *vcs = @[vc1, vc2, vc3];
	
	SBSegmentedViewController *segmentedViewController = [[SBSegmentedViewController alloc] initWithViewControllers:vcs];
	segmentedViewController.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	
	self.navigationItem.titleView = segmentedViewController.segmentedControl;
}
@end
