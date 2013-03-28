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
	
	UIViewController *red = [[UIViewController alloc] initWithNibName:@"RedViewController" bundle:[NSBundle mainBundle]];
	red.title = @"Red";
	
	UIViewController *green = [[UIViewController alloc] initWithNibName:@"GreenViewController" bundle:[NSBundle mainBundle]];
	green.title = @"Green";
	
	UIViewController *blue = [[UIViewController alloc] initWithNibName:@"BlueViewController" bundle:[NSBundle mainBundle]];
	blue.title = @"Blue";
	
	NSArray *vcs = @[red, green, blue];
	
	SBSegmentedViewController *segmentedViewController = [[SBSegmentedViewController alloc] initWithViewControllers:vcs titles:@[@"First", @"Second", @"Third"]];
	segmentedViewController.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedViewController.position = SBSegmentedViewControllerControlPositionToolbar;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:segmentedViewController];
	navigationController.toolbarHidden = NO;
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = navigationController;
	
	[self.window makeKeyAndVisible];
	
	return YES;
}
@end
