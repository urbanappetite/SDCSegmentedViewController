//
//  SDCSegmentedViewController_Tests.m
//  SDCSegmentedViewController Tests
//
//  Created by Scott Berrevoets on 8/17/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SDCSegmentedViewController.h"

static NSString *const SDCViewControllerDefaultTitle1 = @"View controller 1";
static NSString *const SDCViewControllerDefaultTitle2 = @"View controller 2";

@interface SDCSegmentedViewController_Tests : XCTestCase
@property (nonatomic, strong) NSArray *viewControllers;
@end

@implementation SDCSegmentedViewController_Tests

- (void)setUp {
    UIViewController *viewController1 = [[UIViewController alloc] init];
    viewController1.title = SDCViewControllerDefaultTitle1;
    
    UIViewController *viewController2 = [[UIViewController alloc] init];
    viewController2.title = SDCViewControllerDefaultTitle2;
    
    self.viewControllers = @[viewController1, viewController2];
}

- (void)testInitializingWithoutTitlesUsesViewControllerTitles {
    SDCSegmentedViewController *segmentedController = [[SDCSegmentedViewController alloc] initWithViewControllers:self.viewControllers];
    UISegmentedControl *segmentedControl = segmentedController.segmentedControl;
    
    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:0], SDCViewControllerDefaultTitle1, @"");
    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:1], SDCViewControllerDefaultTitle2, @"");
}

- (void)testInitializingWithUserProvidedTitlesUsesThoseTitles {
    NSString *userProvidedTitle1 = @"User title 1";
    NSString *userProvidedTitle2 = @"User title 2";
    
    SDCSegmentedViewController *segmentedController = [[SDCSegmentedViewController alloc] initWithViewControllers:self.viewControllers
                                                                                                           titles:@[userProvidedTitle1, userProvidedTitle2]];
    
    UISegmentedControl *segmentedControl = segmentedController.segmentedControl;

    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:0], userProvidedTitle1, @"");
    XCTAssertEqualObjects([segmentedControl titleForSegmentAtIndex:1], userProvidedTitle2, @"");
}

@end
