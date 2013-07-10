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
	

//	UIViewController *red = [[UIViewController alloc] initWithNibName:@"RedViewController" bundle:[NSBundle mainBundle]];
//	red.title = @"Red";
//	
//	UIViewController *green = [[UIViewController alloc] initWithNibName:@"GreenViewController" bundle:[NSBundle mainBundle]];
//	green.title = @"Green";
//	
//	NSArray *vcs = @[red, green];
//	
//	SBSegmentedViewController *segmentedViewController = [[SBSegmentedViewController alloc] initWithViewControllers:vcs titles:@[@"First", @"Second"]];
//	segmentedViewController.position = SBSegmentedViewControllerControlPositionToolbar;
//	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:segmentedViewController];
//	navigationController.toolbarHidden = NO;
//	
//	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//	self.window.rootViewController = navigationController;
//	
//	[self.window makeKeyAndVisible];
//	
//	UIViewController *blue = [[UIViewController alloc] initWithNibName:@"BlueViewController" bundle:[NSBundle mainBundle]];
//	blue.title = @"Blue";
//	[segmentedViewController addViewController:blue];

	SBSegmentedViewController *segmentedViewController = (SBSegmentedViewController *)[(UINavigationController *)self.window.rootViewController topViewController];
	segmentedViewController.position = SBSegmentedViewControllerControlPositionToolbar;
	[segmentedViewController performSegueWithIdentifier:@"segment1" sender:nil];
	[segmentedViewController performSegueWithIdentifier:@"segment2" sender:nil];
>>>>>>> Add storyboard support
	
	return YES;
}
@end
