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
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic) NSInteger currentSelectedIndex;

@property (nonatomic) BOOL hasAppeared;

@end

@implementation SBSegmentedViewController

#pragma mark - Custom Getters

- (NSMutableArray *)viewControllers {
	if (!_viewControllers)
		_viewControllers = [NSMutableArray array];
    
	return _viewControllers;
}

- (NSMutableArray *)titles {
	if (!_titles)
		_titles = [NSMutableArray array];
    
	return _titles;
}

- (UISegmentedControl *)segmentedControl {
	if (!_segmentedControl) {
		_segmentedControl = [[UISegmentedControl alloc] initWithItems:self.titles];
		_segmentedControl.selectedSegmentIndex = UISegmentedControlSegmentLeft;
		_segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;

		[_segmentedControl addTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventValueChanged];
	}
    
	return _segmentedControl;
}

#pragma mark - Custom Setter

- (void)setPosition:(SBSegmentedViewControllerControlPosition)position {
	_position = position;
	[self moveControlToPosition:position];
}

#pragma mark - Initializers

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
	return [self initWithViewControllers:viewControllers titles:[viewControllers valueForKeyPath:@"@unionOfObjects.title"]];
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles {
	self = [super init];

	_viewControllers = [NSMutableArray array];
	_titles = [NSMutableArray array];

	if (self) {
		[viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
			if ([obj isKindOfClass:[UIViewController class]] && index < [titles count]) {
				UIViewController *viewController = obj;

				[_viewControllers addObject:viewController];
				[_titles addObject:titles[index]];
			}
		}];

		if ([_viewControllers count] == 0 || [_viewControllers count] != [_titles count]) {
			self = nil;
			NSLog(@"SBSegmentedViewController: Invalid configuration of view controllers and titles.");
		} else {
			_currentSelectedIndex = DEFAULT_SELECTED_INDEX;
			[self observeViewController:_viewControllers[_currentSelectedIndex]];
		}
	}

	return self;
}

#pragma mark - View Controller Lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	if (!self.hasAppeared) {
        self.hasAppeared = YES;
        UIViewController *currentViewController = self.viewControllers[self.currentSelectedIndex];
        [self addChildViewController:currentViewController];

        currentViewController.view.frame = self.view.frame;
        [self.view addSubview:currentViewController.view];

        [currentViewController didMoveToParentViewController:self];

		[self updateBarsForViewController:currentViewController];
    }
}

<<<<<<< HEAD
=======
#pragma mark - Content Management

- (void)addViewController:(UIViewController *)viewController {
	if (viewController && viewController.title)
		[self addViewController:viewController withTitle:viewController.title];
	else
		NSLog(@"%@: Can't add view controller (%@) because no title was specified!", NSStringFromClass([self class]), viewController);
}

- (void)addViewController:(UIViewController *)viewController withTitle:(NSString *)title {
	[self.viewControllers addObject:viewController];
	[self.titles addObject:title];
	
	NSInteger newIndex = [self.titles indexOfObject:title];
	[self.segmentedControl insertSegmentWithTitle:title atIndex:newIndex animated:YES];
	
	// If this was the first view controller we added, make it the selected one. We do this during lazy instantiation as well, but at that point setting it to the left most segment has no meaning, because there aren't any segments.
	if (newIndex == 0)
		self.segmentedControl.selectedSegmentIndex = newIndex;
	
	[self.segmentedControl sizeToFit];
}

>>>>>>> Set selected segment index when adding first view controller
#pragma mark - View Controller Containment

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

	UIViewController *currentViewController = self.viewControllers[self.segmentedControl.selectedSegmentIndex];
	[self updateBarsForViewController:currentViewController];
}

- (void)changeViewController:(UISegmentedControl *)segmentedControl {

	UIViewController *oldViewController = self.viewControllers[self.currentSelectedIndex];
	[oldViewController willMoveToParentViewController:nil];
	[self stopObservingViewController:oldViewController];

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

									[self updateBarsForViewController:newViewController];
									[self observeViewController:newViewController];

									self.currentSelectedIndex = segmentedControl.selectedSegmentIndex;
								}
							}];
}

- (void)updateBarsForViewController:(UIViewController *)viewController {
	if (self.position == SBSegmentedViewControllerControlPositionToolbar)
		self.title = viewController.title;
	else if (self.position == SBSegmentedViewControllerControlPositionNavigationBar)
		self.toolbarItems = viewController.toolbarItems;
}

#pragma mark - KVO

- (void)observeViewController:(UIViewController *)viewController {
	[viewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
	[viewController addObserver:self forKeyPath:@"toolbarItems" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)stopObservingViewController:(UIViewController *)viewController {
	[self.viewControllers[self.currentSelectedIndex] removeObserver:self forKeyPath:@"title"];
	[self.viewControllers[self.currentSelectedIndex] removeObserver:self forKeyPath:@"toolbarItems"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self updateBarsForViewController:object];
}

- (void)dealloc {
	[self stopObservingViewController:self.viewControllers[self.currentSelectedIndex]];
}

@end
