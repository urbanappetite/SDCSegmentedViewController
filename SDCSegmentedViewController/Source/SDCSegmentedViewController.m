//
//  SDCSegmentedViewController.m
//  SDCSegmentedViewController
//
//  Created by Scott Berrevoets on 3/15/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCSegmentedViewController.h"

@interface SDCSegmentedViewController ()
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSString *segueNames;

@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeRecognizer;

@property (nonatomic, strong) NSHashTable *loadedViewControllers;

@property (strong, nonatomic) NSMutableDictionary *hasAdjustedContentOffsetDict;

@property (nonatomic) BOOL lockContentOffset;

@property (nonatomic) UIView *originalTitleView;

@end

@implementation SDCSegmentedViewController

- (NSMutableArray *)viewControllers {
	if (!_viewControllers)
		_viewControllers = [NSMutableArray array];
    return _viewControllers;
}

- (NSMutableArray *)segmentTitles {
	if (!_segmentTitles)
		_segmentTitles = [NSMutableArray array];
    return _segmentTitles;
}

- (NSHashTable *)loadedViewControllers {
    if (!_loadedViewControllers)
        _loadedViewControllers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    return _loadedViewControllers;
}

- (void)setPosition:(SDCSegmentedViewControllerControlPosition)position {
	_position = position;
	[self moveControlToPosition:position];
}

- (void)setSwitchesWithSwipe:(BOOL)switchesWithSwipe {
    if (_switchesWithSwipe != switchesWithSwipe) {
        if (switchesWithSwipe) {
            self.leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchViewControllerWithSwipe:)];
            self.leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            
            self.rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchViewControllerWithSwipe:)];
            self.rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
            
            [self.view addGestureRecognizer:self.leftSwipeRecognizer];
            [self.view addGestureRecognizer:self.rightSwipeRecognizer];
        } else {
            [self.view removeGestureRecognizer:self.leftSwipeRecognizer];
            [self.view removeGestureRecognizer:self.rightSwipeRecognizer];
        }
    }
}

#pragma mark - Initializers

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
	return [self initWithViewControllers:viewControllers titles:[viewControllers valueForKeyPath:@"@unionOfObjects.title"]];
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles {
	self = [super init];
	
	if (self) {
		[self createSegmentedControl];
        
        _currentSelectedIndex = UISegmentedControlNoSegment;
        _transitioningToSelectedIndex = NSNotFound;
        
		_viewControllers = [NSMutableArray array];
		_segmentTitles = [NSMutableArray array];
        _firstViewIndex = -1;
        _hasAdjustedContentOffsetDict = [NSMutableDictionary dictionary];
        
		[viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
			if ([obj isKindOfClass:[UIViewController class]] && index < [titles count])
				[self addViewController:obj withTitle:titles[index]];
		}];
		
		if ([_viewControllers count] == 0 || [_viewControllers count] != [_segmentTitles count]) {
			self = nil;
			NSLog(@"%@: Invalid configuration of view controllers and titles.", NSStringFromClass([self class]));
		}
	}
	
	return self;
}

- (void)createSegmentedControl {
	_segmentedControl = [[UISegmentedControl alloc] initWithItems:nil];
	[_segmentedControl addTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventValueChanged];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
	_segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
#endif
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _firstViewIndex = -1;
        _hasAdjustedContentOffsetDict = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)awakeFromNib {
    [self createSegmentedControl];
    _currentSelectedIndex = UISegmentedControlNoSegment;
    _transitioningToSelectedIndex = NSNotFound;

	if ([self.segueNames length] > 0) {
		NSArray *segueNames = [self.segueNames componentsSeparatedByString:@","];
		[self addStoryboardSegments:segueNames];
	}
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.originalTitleView = self.navigationItem.titleView;
    
    self.lockContentOffset = YES;
    
    [self adjustScrollViewInsets];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if ([self.viewControllers count] == 0) {
        
        [self.view setNeedsLayout];
        [super viewWillAppear:animated];

        return;
    }
    
    [self moveControlToPosition:self.position];
    [self.view setNeedsLayout];
    
	[super viewWillAppear:animated];
	
	if (self.currentSelectedIndex == UISegmentedControlNoSegment)
		[self showFirstViewController];
	else if (self.currentSelectedIndex < [self.viewControllers count])
		[self observeViewController:self.viewControllers[self.currentSelectedIndex]];
	
	[self moveControlToPosition:self.position];
    [self.view setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.lockContentOffset = NO;
    
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
    if (self.viewControllers.count == 0) {
        [self adjustScrollViewInsets:self];
        
        return;
    }
    
    NSUInteger selectIndex = self.transitioningToSelectedIndex;
    
    if (selectIndex == NSNotFound) {
        selectIndex = self.currentSelectedIndex;
    }
    
	UIViewController *childViewController = self.viewControllers[selectIndex];
	[self adjustScrollViewInsets:childViewController];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    
    if (self.viewControllers.count == 0) {
        return;
    }
    
	[self stopObservingViewController:self.viewControllers[self.currentSelectedIndex]];
}

#pragma mark - View Management

- (void)adjustScrollViewInsets
{
    if (self.viewControllers.count == 0) {
        [self adjustScrollViewInsets:self];
        
        return;
    }
    
    NSUInteger index = self.currentSelectedIndex;
    
    if (self.currentSelectedIndex == -1) {
        index = 0;
    }
    
    [self adjustScrollViewInsets:self.viewControllers[index]];
}

- (void)adjustScrollViewInsets:(UIViewController *)viewController {
    
    UIScrollView *scrollView;
    
    UIView *topView = viewController.view;
    UIView *childView = nil;
    UIView *secondLevelChildView = nil;
    
    if (![topView isKindOfClass:[UIScrollView class]]) {
        
        if (topView.subviews.count > 0) {
            childView = topView.subviews[0];
            
            if (![childView isKindOfClass:[UIScrollView class]]) {
            
                if (childView.subviews.count > 0) {
                    secondLevelChildView = childView.subviews[0];
                    
                    if ([secondLevelChildView isKindOfClass:[UIScrollView class]]) {
                        scrollView = secondLevelChildView;
                    }

                }
            } else {
                scrollView = childView;
            }
            
        }
    } else {
        scrollView = topView;
    }
    
    
    if (scrollView && self.viewControllers.count == 0) {
    
        viewController.automaticallyAdjustsScrollViewInsets = NO;
        scrollView.contentInset = UIEdgeInsetsMake(20.0f + self.extraTopOffset, 0.0f, self.bottomLayoutGuide.length, 0.0f);
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(64.0f + self.extraScrollInset, 0.0f, self.bottomLayoutGuide.length, 0.0f);
        
        if (scrollView.contentOffset.y == 0) {
            scrollView.contentOffset = CGPointMake(0.0f, (self.extraTopOffset + 20) * -1);
        }
        
        return;
    }
    
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    
    CGPoint contentOffset = scrollView.contentOffset;

    
	if (scrollView) {
        
        NSLog(@"Start: %f offset: %f", scrollView.contentInset.top, scrollView.contentOffset.y);

        NSUInteger index = [self.viewControllers indexOfObject:viewController];
    
        UIEdgeInsets scrollUnsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
        scrollUnsets.top += self.extraScrollInset;
    
        scrollView.scrollIndicatorInsets = scrollUnsets;
        
        UIEdgeInsets insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
        insets.top += self.extraTopOffset;
        
        scrollView.contentInset = insets;
        
        if (self.lockContentOffset ||  scrollView.contentOffset.y == 0 || scrollView.contentInset.top == 0 || scrollView.contentInset.top == self.extraTopOffset) {
            scrollView.contentOffset = CGPointMake(0.0f,  (-64.0f - self.extraTopOffset));
        }
  
        NSLog(@"End: top: %f offset: %f", scrollView.contentInset.top, scrollView.contentOffset.y);
    }
}

- (CGFloat)extraTopOffset
{
    return 0.0f;
}

- (CGFloat)extraScrollInset
{
    return 0.0f;
}

- (void)reset
{
    [self createSegmentedControl];
    
    _currentSelectedIndex = UISegmentedControlNoSegment;
    _transitioningToSelectedIndex = NSNotFound;
    
    _viewControllers = [NSMutableArray array];
    _segmentTitles = [NSMutableArray array];
    _firstViewIndex = -1;
    _hasAdjustedContentOffsetDict = [NSMutableDictionary dictionary];
}

- (void)moveControlToPosition:(SDCSegmentedViewControllerControlPosition)newPosition {
    
    if (self.viewControllers.count <= 1) {
        self.navigationItem.titleView = self.originalTitleView;
    } else {
        switch (newPosition) {
            case SDCSegmentedViewControllerControlPositionNavigationBar:
            {
                self.navigationItem.titleView = self.segmentedControl;
                
                break;
            }
            case SDCSegmentedViewControllerControlPositionToolbar: {
                UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                UIBarButtonItem *control = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
                
                self.toolbarItems = @[flexible, control, flexible];
                break;
            }
        }
        
    }
    
    if ([self.viewControllers count] > 0 && self.currentSelectedIndex != UISegmentedControlNoSegment)
        [self updateBarsForViewController:self.viewControllers[self.segmentedControl.selectedSegmentIndex]];
}

- (void)updateBarsForViewController:(UIViewController *)viewController {
	if (self.position == SDCSegmentedViewControllerControlPositionToolbar)
		self.title = viewController.title;
	else if (self.position == SDCSegmentedViewControllerControlPositionNavigationBar)
		self.toolbarItems = viewController.toolbarItems;
    
	self.navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems;
	self.navigationItem.leftBarButtonItems = viewController.navigationItem.leftBarButtonItems;
}

#pragma mark - View Controller Containment

- (void)addStoryboardSegments:(NSArray *)segments {
	[segments enumerateObjectsUsingBlock:^(NSString *segment, NSUInteger idx, BOOL *stop) {
		[self performSegueWithIdentifier:segment sender:self];
	}];
}

- (void)addViewController:(UIViewController *)viewController {
	if (viewController && viewController.title)
		[self addViewController:viewController withTitle:viewController.title];
	else
		NSLog(@"%@: Can't add view controller (%@) because no title was specified!", NSStringFromClass([self class]), viewController);
}

- (void)addViewController:(UIViewController *)viewController withTitle:(NSString *)title {
	[self.viewControllers addObject:viewController];
	[self.segmentTitles addObject:title];
	[self addChildViewController:viewController];
    
    NSUInteger index = self.viewControllers.count - 1;
    [UIView setAnimationsEnabled:NO];
	[self.segmentedControl insertSegmentWithTitle:self.segmentTitles[index] atIndex:index animated:NO];
    [self resizeSegmentedControl];
    [UIView setAnimationsEnabled:YES];
}

//- (void)updateSegmentedControl
//{
//    [UIView setAnimationsEnabled:NO];
//    [self createSegmentedControl];
//    
//    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL * _Nonnull stop) {
//        [self.segmentedControl insertSegmentWithTitle:viewController.title atIndex:idx animated:NO];
//    }];
//    
//    self.navigationItem.titleView = self.segmentedControl;
//    
//    [self resizeSegmentedControl];
//    self.segmentedControl.selectedSegmentIndex = self.currentSelectedIndex;
//    
//    [UIView setAnimationsEnabled:YES];
//    
//}

#pragma mark - View Controller Transitioning

- (void)showFirstViewController {
    if (self.firstViewIndex == -1) {
        self.firstViewIndex = 0;
    }
	UIViewController *firstViewController = self.viewControllers[self.firstViewIndex];
	[self.view addSubview:firstViewController.view];
	
	[self willTransitionToViewController:firstViewController];
	[self didTransitionToViewController:firstViewController];
}

- (void)switchViewControllerWithSwipe:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (self.currentSelectedIndex < [self.viewControllers count] - 1)
            [self transitionToViewControllerWithIndex:self.currentSelectedIndex + 1];
    } else {
        if (self.currentSelectedIndex > 0)
            [self transitionToViewControllerWithIndex:self.currentSelectedIndex - 1];
    }
}

- (void)willTransitionToViewController:(UIViewController *)viewController {
	if (self.currentSelectedIndex != UISegmentedControlNoSegment) {
		UIViewController *oldViewController = self.viewControllers[self.currentSelectedIndex];
		[oldViewController willMoveToParentViewController:nil];
		[self stopObservingViewController:oldViewController];
	}
	
	viewController.view.frame = self.view.frame;
    
    self.transitioningToSelectedIndex = [self.viewControllers indexOfObject:viewController];
    [self fixViewControllerScrollOffset:viewController];
    [self adjustScrollViewInsets:viewController];
    
    if ([self.delegate respondsToSelector:@selector(segmentedViewController:willTransitionToViewController:)])
        [self.delegate segmentedViewController:self willTransitionToViewController:viewController];
}

- (void)didTransitionToViewController:(UIViewController *)viewController {
	[viewController didMoveToParentViewController:self];
	[self updateBarsForViewController:viewController];
	[self observeViewController:viewController];
	
	self.segmentedControl.selectedSegmentIndex = [self.viewControllers indexOfObject:viewController];
    self.currentSelectedIndex = [self.viewControllers indexOfObject:viewController];
    
    [self viewControllerHasLoaded:viewController];
    self.transitioningToSelectedIndex = NSNotFound;
    
    if ([self.delegate respondsToSelector:@selector(segmentedViewController:didTransitionToViewController:)])
        [self.delegate segmentedViewController:self didTransitionToViewController:viewController];
}

- (void)transitionToViewControllerWithIndex:(NSUInteger)index {
    UIViewController *oldViewController = self.viewControllers[self.currentSelectedIndex];
	UIViewController *newViewController = self.viewControllers[index];
    
    if (!oldViewController) {
        return;
    }
    
    if (!newViewController) {
        return;
    }
    
	
	[self willTransitionToViewController:newViewController];
	[self transitionFromViewController:oldViewController
					  toViewController:newViewController
							  duration:0
							   options:UIViewAnimationOptionTransitionNone
							animations:nil
							completion:^(BOOL finished) {
								[self didTransitionToViewController:newViewController];
							}];
}

- (void)changeViewController:(UISegmentedControl *)segmentedControl {
	[self transitionToViewControllerWithIndex:segmentedControl.selectedSegmentIndex];
}

#pragma mark - KVO

- (void)observeViewController:(UIViewController *)viewController {
	[viewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
	[viewController addObserver:self forKeyPath:@"toolbarItems" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)stopObservingViewController:(UIViewController *)viewController {
	[viewController removeObserver:self forKeyPath:@"title"];
	[viewController removeObserver:self forKeyPath:@"toolbarItems"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	[self updateBarsForViewController:object];
}

#pragma mark - Segmented Control Width

- (void)resizeSegmentedControl {
	if (self.segmentedControlWidth == 0) {
		[self.segmentedControl sizeToFit];
		return;
	}
	
	for (int x = 0; x < self.segmentedControl.numberOfSegments; x++) {
		[self.segmentedControl setWidth:self.segmentedControlWidth / self.segmentedControl.numberOfSegments
					  forSegmentAtIndex:x];
	}
}

- (void)setSegmentedControlWidth:(NSUInteger)segmentedControlWidth {
	_segmentedControlWidth = segmentedControlWidth;
	[self resizeSegmentedControl];
}


#pragma mark - Loaded View Controllers

- (void)viewControllerHasLoaded:(UIViewController *)viewController
{
    if ([self.loadedViewControllers containsObject:viewController]) {
        return;
    }
    
    [self.loadedViewControllers addObject:viewController];
    
}


#pragma mark - Offset Fix

- (void)fixViewControllerScrollOffset:(UIViewController *)viewController
{
    if ([self.loadedViewControllers containsObject:viewController]) {
        return;
    }
    
    if (self.viewControllers.count == 0) {
        return;
    }
    
    UIScrollView *scrollView;
    
    UIView *topView = viewController.view;
    UIView *childView = nil;
    UIView *secondLevelChildView = nil;
    
    if (![topView isKindOfClass:[UIScrollView class]]) {
        
        if (topView.subviews.count > 0) {
            childView = topView.subviews[0];
            
            if (![childView isKindOfClass:[UIScrollView class]]) {
                
                if (childView.subviews.count > 0) {
                    secondLevelChildView = childView.subviews[0];
                    
                    if ([secondLevelChildView isKindOfClass:[UIScrollView class]]) {
                        scrollView = secondLevelChildView;
                    }
                    
                }
            } else {
                scrollView = childView;
            }
            
        }
    } else {
        scrollView = topView;
    }
    
    if (scrollView) {;
        [scrollView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f) animated:NO];
    }
}


#pragma mark - Segmented Control Methods

- (void)selectViewControllerWithIndex:(NSInteger)index
{
    if (self.view.window) {
        
        self.segmentedControl.selectedSegmentIndex = index;
        [self changeViewController:self.segmentedControl];
    } else {
        _firstViewIndex = index;
    }
}

@end
