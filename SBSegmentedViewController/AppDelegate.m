//
//  AppDelegate.m
//  SBSegmentedViewController
//
//  Created by Scott Berrevoets on 3/15/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "AppDelegate.h"
#import "SBSegmentedViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	UIViewController *vc1 = [[UIViewController alloc] init];
	vc1.title = @"Title 1";
	
	UIViewController *vc2 = [[UIViewController alloc] init];
	vc2.title = @"Title 2";
	
	UIViewController *vc3 = [[UIViewController alloc] init];
	vc3.title = @"Title 3";
	
	UILabel *label1 = [[UILabel alloc] init];
	label1.text = @"Label 1";
	[label1 sizeToFit];
	
	UILabel *label2 = [[UILabel alloc] init];
	label2.text = @"Label 2";
	[label2 sizeToFit];
	
	UILabel *label3 = [[UILabel alloc] init];
	label3.text = @"Label 3";
	[label3 sizeToFit];
	
	[vc1.view addSubview:label1];
	[vc2.view addSubview:label2];
	[vc3.view addSubview:label3];
	
	NSArray *vcs = @[vc1, vc2, vc3];
	
	SBSegmentedViewController *segmentedViewController = [[SBSegmentedViewController alloc] initWithViewControllers:vcs];
	segmentedViewController.position = SBSegmentedViewControllerControlPositionToolbar;
	segmentedViewController.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:segmentedViewController];
	navigationController.toolbarHidden = NO;
	
	self.window.rootViewController = navigationController;
	
	return YES;
}
@end
