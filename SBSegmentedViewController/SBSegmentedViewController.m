//
//  SBSegmentedViewController.m
//  SBSegmentedViewController
//
//  Created by Scott Berrevoets on 3/15/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SBSegmentedViewController.h"

@interface SBSegmentedViewController ()
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@end

@implementation SBSegmentedViewController

- (id)initWithViewControllers:(NSArray *)viewControllers {
	
	self = [super init];
	
	if (self) {
		_viewControllers = viewControllers;
		[self initiateSegmentedControl];
	}
	
	return self;
}

- (void)initiateSegmentedControl {
	
	NSArray *segmentedControlItems = [self.viewControllers valueForKeyPath:@"@unionOfObjects.title"];
	self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedControlItems];
	
	
}

@end
