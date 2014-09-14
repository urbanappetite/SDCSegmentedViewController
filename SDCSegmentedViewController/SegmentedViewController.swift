//
//  SegmentedViewController.swift
//  SDCSegmentedViewController
//
//  Created by Scott Berrevoets on 8/29/14.
//  Copyright (c) 2014 Scott Berrevoets. All rights reserved.
//

import UIKit

public protocol SegmentedViewControllerDelegate {
	func segmentedViewController(sender: SegmentedViewController, didTransitionToViewController: UIViewController)
}

public enum SegmentedViewControllerControlPosition {
	case NavigationBar
	case Toolbar
}

@objc(SDCSegmentedViewController)
public class SegmentedViewController: UIViewController {
	typealias ChildViewController = (viewController: UIViewController, title: NSString)
	
	
	public lazy var segmentedControl: UISegmentedControl = {
		return self.createSegmentedControl()
		}()
	
	public var position = SegmentedViewControllerControlPosition.NavigationBar
	public var currentSelectedIndex = UISegmentedControlNoSegment
	public var segmentedControlWidth: CGFloat = 0 {
		didSet {
			resizeSegmentedControl()
		}
	}
	
	private let leftSwipeRecognizer: UISwipeGestureRecognizer!
	private let rightSwipeRecognizer: UISwipeGestureRecognizer!
	public var switchesWithSwipe: Bool = false {
		willSet {
			if newValue {
				view.addGestureRecognizer(leftSwipeRecognizer)
				view.addGestureRecognizer(rightSwipeRecognizer)
			} else {
				view.removeGestureRecognizer(leftSwipeRecognizer)
				view.removeGestureRecognizer(rightSwipeRecognizer)
			}
		}
	}
	
	public var segueNames = ""
	
	public var delegate: SegmentedViewControllerDelegate?
	
	var items: [ChildViewController] = []
	
	//MARK: - Initialization
	
	required public init(coder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
	init(items: [(viewController: UIViewController, title: String?)]) {
		for (index, pair) in enumerate(items) {
			if let viewControllerTitle = pair.title {
				self.items.append((pair.viewController, viewControllerTitle))
			} else {
				if let viewControllerTitle = pair.viewController.title {
					self.items.append((pair.viewController, viewControllerTitle))
				} else {
					println("No title provided for view controller \(pair.viewController)")
				}
			}
		}
		
		super.init()
		
		leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "switchViewControllerWithSwipe:")
		leftSwipeRecognizer.direction = .Left
		
		rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "switchViewControllerWithSwipe:")
		rightSwipeRecognizer.direction = .Right
		
		initializeViewControllers()
	}
	
	func initializeViewControllers() {
		for (index, pair) in enumerate(items) {
			addViewController(pair, index: index)
		}
	}
	
	func createSegmentedControl() -> UISegmentedControl {
		let segmentedControl = UISegmentedControl()
		segmentedControl.addTarget(self, action: "switchViewController:", forControlEvents: .ValueChanged)
		return segmentedControl
	}
	
	//MARK: - View Controller Lifecycle
	
	override public func awakeFromNib() {
		super.awakeFromNib()
		
		if countElements(segueNames) > 0 {
			let segues = segueNames.componentsSeparatedByString(",")
			addStoryboardSegments(segues)
		}
	}
	
	override public func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if items.count == 0 {
			fatalError("SDCSegmentedViewController has no view controllers it can display")
		}
		
		if currentSelectedIndex == UISegmentedControlNoSegment {
			showFirstViewController()
		} else if (currentSelectedIndex < items.count) {
			observeViewController(items[currentSelectedIndex].viewController)
		}
		
		moveControlToPosition(position)
	}
	
	override public func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		adjustScrollViewInsets(items[currentSelectedIndex].viewController)
	}
	
	override public func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		stopObservingViewController(items[currentSelectedIndex].viewController)
	}
	
	//MARK: - View Maintenance
	
	private func adjustScrollViewInsets(viewController: UIViewController) {
		if viewController.view is UIScrollView {
			let insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
			
			let scrollView = viewController.view as UIScrollView
			scrollView.contentInset = insets
			scrollView.scrollIndicatorInsets = insets
		}
	}
	
	private func updateBarsForViewController(viewController: UIViewController) {
		switch position {
		case .NavigationBar:
			title = viewController.title
		case .Toolbar:
			toolbarItems = viewController.toolbarItems
		}
		
		navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem
		navigationItem.leftBarButtonItem = viewController.navigationItem.leftBarButtonItem
	}
	
	private func moveControlToPosition(position: SegmentedViewControllerControlPosition) {
		switch position {
		case .NavigationBar:
			navigationItem.titleView = segmentedControl
		case .Toolbar:
			let flexible = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
			let control = UIBarButtonItem(customView: segmentedControl)
			
			toolbarItems = [flexible, control, flexible]
		}
		
		if items.count > 0 && currentSelectedIndex != UISegmentedControlNoSegment {
			updateBarsForViewController(items[currentSelectedIndex].viewController)
		}
	}
	
	//MARK: - View Controller Containment
	
	public func addStoryboardSegments(segues: [String]) {
		for (_, segue) in enumerate(segues) {
			performSegueWithIdentifier(segue, sender: self)
		}
	}
	
	private func addViewController(pair: ChildViewController, index: Int) {
		addChildViewController(pair.viewController)
		
		segmentedControl.insertSegmentWithTitle(title, atIndex: index, animated: true)
		resizeSegmentedControl()
	}
	
	//MARK: - View Controller Transitioning
	
	private func showFirstViewController() {
		let viewController = items.first!.viewController
		
		view.addSubview(viewController.view)
		
		willTransitionToViewController(viewController)
		didTransitionToViewController(viewController)
	}
	
	private func switchViewController(sender: UISegmentedControl!) {
		transitionToViewControllerWithIndex(sender.selectedSegmentIndex)
	}
	
	private func switchViewControllerWithSwipe(sender: UISwipeGestureRecognizer) {
		if sender.direction == .Left {
			if currentSelectedIndex < items.count - 1 {
				transitionToViewControllerWithIndex(currentSelectedIndex + 1)
			}
		} else if sender.direction == .Right {
			if currentSelectedIndex > 0 {
				transitionToViewControllerWithIndex(currentSelectedIndex - 1)
			}
		}
	}
	
	private func willTransitionToViewController(viewController: UIViewController) {
		if currentSelectedIndex != UISegmentedControlNoSegment {
			let oldViewController = items[currentSelectedIndex].viewController
			oldViewController.willMoveToParentViewController(nil)
			
			stopObservingViewController(oldViewController)
		}
		
		viewController.view.frame = self.view.frame
		adjustScrollViewInsets(viewController)
	}
	
	private func transitionToViewControllerWithIndex(index: Int) {
		let oldViewController = items[currentSelectedIndex].viewController
		let newViewController = items[index].viewController
		
		willTransitionToViewController(newViewController)
		
		transitionFromViewController(oldViewController,
			toViewController: newViewController,
			duration: 0.2,
			options: .TransitionNone,
			animations: {}) { _ in
				self.didTransitionToViewController(newViewController)
		}
	}
	
	private func didTransitionToViewController(viewController: UIViewController) {
		viewController.didMoveToParentViewController(self)
		
		updateBarsForViewController(viewController)
		observeViewController(viewController)
		
		for (index, pair) in enumerate(items) {
			if pair.viewController == viewController {
				segmentedControl.selectedSegmentIndex = index
				currentSelectedIndex = index
				
				break
			}
		}
		
		delegate?.segmentedViewController(self, didTransitionToViewController: viewController)
	}
	
	//MARK: - KVO
	
	private func observeViewController(viewController: UIViewController) {
		viewController.addObserver(self, forKeyPath: "title", options: .New, context: nil)
		viewController.addObserver(self, forKeyPath: "toolbarItems", options: .New, context: nil)
	}
	
	private func stopObservingViewController(viewController: UIViewController) {
		viewController.removeObserver(self, forKeyPath: "title")
		viewController.removeObserver(self, forKeyPath: "toolbarItems")
	}
	
	override public func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!,
		change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
			updateBarsForViewController(object as UIViewController)
	}
	
	//MARK: Segmented Control Width
	
	private func resizeSegmentedControl() {
		if (segmentedControlWidth == 0) {
			segmentedControl.sizeToFit()
			return
		}
		
		for i in 0 ..< segmentedControl.numberOfSegments {
			let segmentWidth = segmentedControlWidth / CGFloat(segmentedControl.numberOfSegments)
			segmentedControl.setWidth(segmentWidth, forSegmentAtIndex: i)
		}
	}
	
}
