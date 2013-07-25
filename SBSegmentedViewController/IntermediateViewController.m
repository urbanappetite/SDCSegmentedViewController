//
//  IntermediateViewController.m
//  SBSegmentedViewController
//
//  Created by Scott Berrevoets on 7/25/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "IntermediateViewController.h"
#import "SBSegmentedViewController.h"

@interface IntermediateViewController ()

@end

@implementation IntermediateViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	SBSegmentedViewController *segmentedViewController = segue.destinationViewController;
	segmentedViewController.position = SBSegmentedViewControllerControlPositionNavigationBar;
	[segmentedViewController addStoryboardSegments:@[@"segment1", @"segment2"]];
}

@end
