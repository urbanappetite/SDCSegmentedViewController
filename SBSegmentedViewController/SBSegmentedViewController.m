//
//  SBSegmentedViewController.m
//  SBSegmentedViewController
//
//  Created by Scott Berrevoets on 3/15/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SBSegmentedViewController.h"

@interface SBSegmentedViewController ()
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@end

@implementation SBSegmentedViewController

- (NSMutableArray *)viewControllers {
	if (!_viewControllers)
		_viewControllers = [NSMutableArray array];
	return _viewControllers;
}

- (id)initWithViewControllers:(NSArray *)viewControllers {
	
	self = [super init];
	
	if (self) {
		
		[viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([obj isKindOfClass:[UIViewController class]]) {
				
				UIViewController *viewController = obj;
				
				[self addChildViewController:viewController];
				[viewController didMoveToParentViewController:self];
				
				[self.viewControllers addObject:viewController];
			}
		}];
		
		[self initiateSegmentedControl];
	}
	
	return self;
}

- (void)initiateSegmentedControl {
	
	NSArray *segmentedControlItems = [self.viewControllers valueForKeyPath:@"@unionOfObjects.title"];
	self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedControlItems];
	self.segmentedControl.selectedSegmentIndex = 0;
	
	[self.segmentedControl addTarget:self action:@selector(changeViewController) forControlEvents:UIControlEventValueChanged];
	
	switch (self.position) {
		case SBSegmentedViewControllerControlPositionNavigationBar:
			self.navigationItem.titleView = self.segmentedControl;
			break;
		case SBSegmentedViewControllerControlPositionToolbar: {
			
			UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
			
			self.toolbarItems = @[flexible, self.segmentedControl, flexible];
			break;
		}
		default:
			break;
	}
}

- (void)changeViewController {
	
}

@end
