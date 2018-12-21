//
//  ScrollableViewController.swift
//  AnimatedSwipableViewController
//
//  Created by Guillaume Bourachot on 10/07/2017.
//  Copyright © 2017 Guillaume Bourachot. All rights reserved.
//

import UIKit

public class ScrollableViewController: UIViewController, UIScrollViewDelegate {
    
    public enum CompletionAction {
        case close
        case mainAction
    }
    
    //MARK: - Variables
    private let scrollView = UIScrollView()
    private var isAnimatingOnBoarding = false
    
    public var addPagingIndicatorView : Bool = false
    public var pageIndicatorFrameHeight : CGFloat = 50
    public var showOnBoardingAnimation : Bool = true
    public var contentViewControllers: [UIViewController] = []
    public var startingAnimationDelay = 0.0
    public var halfwayAnimationDelay = 0.0
    public var swippingWidthRatio = 0.1
    public var startingIndex = 0
    public var completionHandler: ((_ action : CompletionAction)->())? = nil
    public var mainActionImage: UIImage? = nil
    public var displayedViewController: UIViewController? = nil
    private var pageIndicator = GBCollectionViewPagingView()
    
    //MARK: - Life cycle
    override public func viewDidLoad(){
        super.viewDidLoad()
        self.scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.white
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        self.view = scrollView
        if self.addPagingIndicatorView {
            self.view = UIView(frame: CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size))
            self.view.backgroundColor = UIColor.black
            self.scrollView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height - self.pageIndicatorFrameHeight))
            self.view.addSubview(self.scrollView)
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if showOnBoardingAnimation {
            let width: CGFloat = CGFloat(contentViewControllers.count) * self.view.bounds.size.width
            if self.addPagingIndicatorView {
                scrollView.contentSize = CGSize.init(width: width, height: self.view.bounds.size.height - pageIndicatorFrameHeight)
            } else {
                scrollView.contentSize = CGSize.init(width: width, height: self.view.bounds.size.height)
            }
            layoutViewController(fromIndex: 0, toIndex: 0)
            self.scroll(to: self.startingIndex, animated: false)
        }
        self.setUpNavigationBar()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showOnBoardingAnimation && self.contentViewControllers.count > 1{
            DispatchQueue.main.asyncAfter(deadline: .now() + self.startingAnimationDelay) {
                self.onBoardingAnimation()
            }
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_quizz_icon"), style: .done, target: self, action: #selector(close))
        if let actionImage = self.mainActionImage {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: actionImage, style: .done, target: self, action: #selector(mainAction))
        }
        
    }
    
    //MARK: - UI Functions
    private func setUpNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.init(named: "appMainColor") ?? UIColor.blue
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
    }
    
    @objc private func close() {
        self.completionHandler?(.close)
        self.completionHandler = nil
    }
    
    @objc private func mainAction() {
        self.completionHandler?(.mainAction)
    }
    
    //MARK: - UIScrollViewDelegate
    private func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let fromIndex = floor(scrollView.bounds.origin.x  / scrollView.bounds.size.width)
        let toIndex = floor((scrollView.bounds.maxX - 1) / scrollView.bounds.size.width)
        layoutViewController(fromIndex: Int(fromIndex), toIndex: Int(toIndex))
    }
    
    private func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if isAnimatingOnBoarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.halfwayAnimationDelay) {
                self.isAnimatingOnBoarding = false
                self.scroll(to: self.startingIndex, animated: true)
                self.showOnBoardingAnimation = false
            }
        }
    }
    
    private func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = round(targetContentOffset.pointee.x / self.view.bounds.size.width) * self.view.bounds.size.width
        targetContentOffset.pointee.x = offset
    }
    
    private func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !isAnimatingOnBoarding {
            self.pageIndicator.selectedPage = Int(floor((self.scrollView.contentOffset.x - self.scrollView.bounds.size.width / 2) / self.scrollView.bounds.size.width) + 1)
        }
    }
    
    //MARK: - Scroll functions
    private func scroll(to index: Int, animated: Bool){
        self.scrollView.setContentOffset(CGPoint.init(x: CGFloat(index) * self.view.bounds.size.width, y: 0), animated: animated)
    }
    
    //MARK: - Animation function
    func onBoardingAnimation() {
        if self.startingIndex == (self.contentViewControllers.count - 1) {
            self.scrollView.setContentOffset(CGPoint.init(x: (CGFloat(self.startingIndex) - 0.2) * self.view.bounds.size.width, y: 0), animated: true)
        }else {
            self.scrollView.setContentOffset(CGPoint.init(x: (CGFloat(self.startingIndex) + 0.2) * self.view.bounds.size.width, y: 0), animated: true)
        }
        isAnimatingOnBoarding = true
    }
    
    private func layoutViewController(fromIndex: Int, toIndex: Int) {
        for i in 0 ..< contentViewControllers.count {
            // Remove views that should not be visible anymore
            if (contentViewControllers[i].view.superview != nil && (i < fromIndex || i > toIndex)) {
                contentViewControllers[i].willMove(toParent: nil)
                contentViewControllers[i].view.removeFromSuperview()
                contentViewControllers[i].removeFromParent()
            }
            
            // Add views that are now visible
            if (contentViewControllers[i].view.superview == nil && (i >= fromIndex && i <= toIndex)) {
                var viewFrame = self.view.bounds
                viewFrame.origin.x = CGFloat(i) * self.view.bounds.size.width
                contentViewControllers[i].view.frame = viewFrame
                self.addChild(contentViewControllers[i])
                scrollView.addSubview(contentViewControllers[i].view)
                contentViewControllers[i].didMove(toParent: self)
                self.displayedViewController = self.contentViewControllers[fromIndex]
            }
        }
        if self.addPagingIndicatorView {
            self.pageIndicator = GBCollectionViewPagingView.init(pageCount: contentViewControllers.count, frame: CGRect.init(x: 0, y: self.view.bounds.height - self.pageIndicatorFrameHeight, width: self.view.bounds.width, height: self.pageIndicatorFrameHeight))
            self.scrollView.backgroundColor = UIColor.black
            self.pageIndicator.backgroundColor = UIColor.black
            self.pageIndicator.filledColor = UIColor.white
            self.pageIndicator.emptyColor = UIColor.gray
            self.pageIndicator.selectedPage = 0
            self.pageIndicator.indicatorSpacing = 5
            self.pageIndicator.contentHeight = 10
            let leftOffset = (self.view.bounds.width - self.pageIndicator.intrinsicContentSize.width) / 2
            self.pageIndicator.frame = CGRect.init(origin: CGPoint(x: leftOffset, y: self.view.bounds.height - self.pageIndicatorFrameHeight), size: self.pageIndicator.frame.size)
            self.view.addSubview(self.pageIndicator)
        }
    }
}
