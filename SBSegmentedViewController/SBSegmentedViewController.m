//
//  SBSegmentedViewController.m
//  SBSegmentedViewController
//
//  Created by Scott Berrevoets on 3/15/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SBSegmentedViewController.h"

#define DEFAULT_SELECTED_INDEX 0

@interface SBSegmentedViewController ()
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic) NSInteger currentSelectedIndex;
@end

@implementation SBSegmentedViewController

- (NSMutableArray *)viewControllers {
	if (!_viewControllers)
		_viewControllers = [NSMutableArray array];
	return _viewControllers;
}

- (void)setPosition:(SBSegmentedViewControllerControlPosition)position {
	_position = position;
	
	if (!self.segmentedControl)
		[self initiateSegmentedControlAtPosition:position];
	else
		[self moveControlToPosition:position];
}

- (id)initWithViewControllers:(NSArray *)viewControllers {
	
	self = [super init];
	
	if (self) {
		[viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([obj isKindOfClass:[UIViewController class]])
				[self.viewControllers addObject:obj];
		}];
	}
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	
	UIViewController *currentViewController = self.viewControllers[DEFAULT_SELECTED_INDEX];
	[self addChildViewController:currentViewController];
	
	currentViewController.view.frame = self.view.frame;
	[self.view addSubview:currentViewController.view];
	
	[currentViewController didMoveToParentViewController:self];
}

- (void)initiateSegmentedControlAtPosition:(SBSegmentedViewControllerControlPosition)position {
	
	NSArray *segmentedControlItems = [self.viewControllers valueForKeyPath:@"@unionOfObjects.title"];
	self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedControlItems];
	self.segmentedControl.selectedSegmentIndex = DEFAULT_SELECTED_INDEX;
	
	[self.segmentedControl addTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventValueChanged];
	
	[self moveControlToPosition:position];
}

- (void)moveControlToPosition:(SBSegmentedViewControllerControlPosition)newPosition {
	
	switch (newPosition) {
		case SBSegmentedViewControllerControlPositionNavigationBar:
			self.navigationItem.titleView = self.segmentedControl;
			break;
		case SBSegmentedViewControllerControlPositionToolbar: {
			
			UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					  target:nil
																					  action:nil];
			UIBarButtonItem *control = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
			
			self.toolbarItems = @[flexible, control, flexible];
			
			UIViewController *currentViewController = self.viewControllers[self.currentSelectedIndex];
			self.title = currentViewController.title;
			break;
		}
	}
}

- (void)changeViewController:(UISegmentedControl *)segmentedControl {
	
	UIViewController *oldViewController = self.viewControllers[self.currentSelectedIndex];
	[oldViewController willMoveToParentViewController:nil];
	
	UIViewController *newViewController = self.viewControllers[segmentedControl.selectedSegmentIndex];
	[self addChildViewController:newViewController];
	newViewController.view.frame = self.view.frame;
	
	[self transitionFromViewController:oldViewController
					  toViewController:newViewController
							  duration:0
							   options:UIViewAnimationOptionTransitionNone
							animations:nil
							completion:^(BOOL finished) {
								if (finished) {
									
									[newViewController didMoveToParentViewController:self];
									
									self.currentSelectedIndex = segmentedControl.selectedSegmentIndex;
									
									if (self.position == SBSegmentedViewControllerControlPositionToolbar)
										self.title = newViewController.title;
								}
							}];
	
}

@end
