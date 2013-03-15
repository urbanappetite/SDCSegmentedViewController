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
			if ([obj isKindOfClass:[UIViewController class]]) {
				
				UIViewController *viewController = obj;
				
				[self addChildViewController:viewController];
				[viewController didMoveToParentViewController:self];
				
				[self.viewControllers addObject:viewController];
			}
		}];
		
		[self.view addSubview:((UIViewController *)viewControllers[DEFAULT_SELECTED_INDEX]).view];
	}
	
	return self;
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
			break;
		}
	}
}

- (void)changeViewController:(UISegmentedControl *)segmentedControl {
	
	[self transitionFromViewController:self.viewControllers[self.currentSelectedIndex]
					  toViewController:self.viewControllers[segmentedControl.selectedSegmentIndex]
							  duration:0
							   options:UIViewAnimationOptionTransitionNone
							animations:nil
							completion:^(BOOL finished) {
								if (finished)
									self.currentSelectedIndex = segmentedControl.selectedSegmentIndex;
							}];
	
}

@end
