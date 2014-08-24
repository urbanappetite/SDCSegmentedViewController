//
//  SDCSegmentedViewController_Tests.m
//  SDCSegmentedViewController Tests
//
//  Created by Scott Berrevoets on 8/17/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "SDCSegmentedViewController.h"

static NSString *const SDCViewControllerDefaultTitle1 = @"View controller 1";
static NSString *const SDCViewControllerDefaultTitle2 = @"View controller 2";

@interface SDCSegmentedViewController_Tests : XCTestCase
@property (nonatomic, strong) SDCSegmentedViewController *segmentedController;
@property (nonatomic, strong) NSArray *viewControllers;
@end

@implementation SDCSegmentedViewController_Tests

- (void)setUp {
    UIViewController *viewController1 = [[UIViewController alloc] init];
    viewController1.title = SDCViewControllerDefaultTitle1;
    
    UIViewController *viewController2 = [[UIViewController alloc] init];
    viewController2.title = SDCViewControllerDefaultTitle2;
    
    self.viewControllers = @[viewController1, viewController2];
    self.segmentedController = [[SDCSegmentedViewController alloc] initWithViewControllers:self.viewControllers];
}

- (void)testInitializingWithoutTitlesUsesViewControllerTitles {
    UISegmentedControl *segmentedControl = self.segmentedController.segmentedControl;
    
    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:0], SDCViewControllerDefaultTitle1, @"");
    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:1], SDCViewControllerDefaultTitle2, @"");
}

- (void)testInitializingWithUserProvidedTitlesUsesThoseTitles {
    NSString *userProvidedTitle1 = @"User title 1";
    NSString *userProvidedTitle2 = @"User title 2";
    
    self.segmentedController = [[SDCSegmentedViewController alloc] initWithViewControllers:self.viewControllers
                                                                                    titles:@[userProvidedTitle1, userProvidedTitle2]];
    UISegmentedControl *segmentedControl = self.segmentedController.segmentedControl;

    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:0], userProvidedTitle1, @"");
    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:1], userProvidedTitle2, @"");
}

- (void)testSegmentedControlShowsInNavigationBarWhenUserWantsItTo {
    self.segmentedController.position = SDCSegmentedViewControllerControlPositionNavigationBar;
    
    XCTAssertEqualObjects(self.segmentedController.segmentedControl, self.segmentedController.navigationItem.titleView, @"");
}

- (void)testSegmentedControlShowsCenteredInToolbarWhenUserWantsItTo {
    self.segmentedController.position = SDCSegmentedViewControllerControlPositionToolbar;
 
    XCTAssertNoThrow(self.segmentedController.toolbarItems[0], @"");
    XCTAssertNoThrow(self.segmentedController.toolbarItems[2], @"");
    
    UIBarButtonItem *segmentedControlItem;
    XCTAssertNoThrow(segmentedControlItem = self.segmentedController.toolbarItems[1], @"");
    XCTAssertEqualObjects(segmentedControlItem.customView, self.segmentedController.segmentedControl, @"");
}

- (void)testAddingViewControllerWithExplicitTitleAfterInitialization {
    NSString *newTitle = @"New title";
    UIViewController *newViewController = [[UIViewController alloc] init];
    
    [self.segmentedController addViewController:newViewController withTitle:newTitle];
    UISegmentedControl *segmentedControl = self.segmentedController.segmentedControl;
    
    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:2], newTitle, @"");
}

- (void)testAddingViewControllerWithImplicitTitleAfterInitialization {
    NSString *newTitle = @"New title";
    UIViewController *newViewController = [[UIViewController alloc] init];
    newViewController.title = newTitle;
    
    [self.segmentedController addViewController:newViewController];
    UISegmentedControl *segmentedControl = self.segmentedController.segmentedControl;
    
    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:2], newTitle, @"");
}

- (void)loadSegmentedControllerFromStoryboardWithIdentifier:(NSString *)identifier {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TestStoryboard" bundle:[NSBundle bundleForClass:[self class]]];
    self.segmentedController = [storyboard instantiateViewControllerWithIdentifier:identifier];
}

- (void)testLoadingViewControllerFromStoryboardAutomaticallyLoadingSegues {
    [self loadSegmentedControllerFromStoryboardWithIdentifier:@"segmentedControllerWithAutomaticSegues"];
    UISegmentedControl *segmentedControl = self.segmentedController.segmentedControl;
    
    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:0], @"First", @"");
    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:1], @"Second", @"");
}

- (void)testLoadingViewControllerFromStoryboardsManuallyPerformingSegues {
    [self loadSegmentedControllerFromStoryboardWithIdentifier:@"segmentedControllerWithoutAutomaticSegues"];
    UISegmentedControl *segmentedControl = self.segmentedController.segmentedControl;
    
    [self.segmentedController addStoryboardSegments:@[@"segment1", @"segment2"]];
    
    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:0], @"First", @"");
    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:1], @"Second", @"");
}

- (id)createMockForDelegate {
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(SDCSegmentedViewControllerDelegate)];
    self.segmentedController.delegate = mockDelegate;
    
    return mockDelegate;
}

- (void)testDelegateMethodIsSent {
    id mockDelegate = [self createMockForDelegate];
    [[mockDelegate expect] segmentedViewController:self.segmentedController didTransitionToViewController:[OCMArg any]];
    
    [self.segmentedController viewWillAppear:NO];
    
    [mockDelegate verify];
}

- (void)testCorrectViewControllerIsReportedInDelegateMethod {
    NSInteger newIndex = 1;
    
    id mockDelegate = [self createMockForDelegate];
    [[mockDelegate expect] segmentedViewController:self.segmentedController didTransitionToViewController:[OCMArg any]];
    [self.segmentedController viewWillAppear:NO];
    
    [[mockDelegate expect] segmentedViewController:self.segmentedController didTransitionToViewController:self.viewControllers[newIndex]];
    [self.segmentedController.segmentedControl setSelectedSegmentIndex:newIndex];
    [self.segmentedController.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
    
    // Delay a little to give the animation time to complete and call the delegate
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    [mockDelegate verify];
}

@end
