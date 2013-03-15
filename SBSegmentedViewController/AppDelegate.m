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
	
	NSArray *vcs = @[vc1, vc2, vc3];
	
	
	SBSegmentedViewController *segmentedViewController = [[SBSegmentedViewController alloc] initWithViewControllers:vcs];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:segmentedViewController];
	
	self.window.rootViewController = navigationController;
	
	return YES;
}
@end
