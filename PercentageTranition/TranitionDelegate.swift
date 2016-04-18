//
//  TranitionDelegate.swift
//  PercentageTranition
//
//  Created by David on 2016/4/17.
//  Copyright © 2016年 David. All rights reserved.
//

import Foundation
import UIKit

public class TransitionDelegate: UIPercentDrivenInteractiveTransition {
	
	private let presentingDuration = 1.0
	private let dismissingDuration = 0.5
	
	private var isPresenting = true
	private var isInteractive = true
	
	// source controller
	private var presentationPanGesture: UIPanGestureRecognizer!
	public var sourceViewController: UIViewController! {
		didSet {
			presentationPanGesture = UIPanGestureRecognizer()
			presentationPanGesture.addTarget(self, action: #selector(presentationPanGestureHandler))
			sourceViewController.view.addGestureRecognizer(presentationPanGesture)
		}
	}
	
	@objc private func presentationPanGestureHandler(gesture: UIPanGestureRecognizer) {
		
		let translation = gesture.translationInView(gesture.view!)
		
		let distance = transfromTranslation(translation.x)
		
		switch gesture.state {
		case .Began:
			isInteractive = true
			sourceViewController.performSegueWithIdentifier("a", sender: nil)
		case .Changed:
			self.updateInteractiveTransition(distance)
		default:
			isInteractive = false
			if distance >= 0.5 {
				self.finishInteractiveTransition()
			} else {
				self.cancelInteractiveTransition()
			}
		}
	}
	
	private func transfromTranslation(amount: CGFloat) -> CGFloat {
		
		return (amount / 350.0)
	}
	
	// destination controller
	private var dismissalPanGesture: UIPanGestureRecognizer!
	public var destinationViewController: UIViewController! {
		didSet {
			dismissalPanGesture = UIPanGestureRecognizer()
			dismissalPanGesture.addTarget(self, action: #selector(dismissalPanGestureHandler))
			destinationViewController.view.addGestureRecognizer(dismissalPanGesture)
		}
	}
	
	@objc private func dismissalPanGestureHandler(gesture: UIPanGestureRecognizer) {
		let translation = gesture.translationInView(gesture.view!)
		
		let distance = transfromTranslation(-translation.x)
		print(distance)
		
		switch gesture.state {
		case .Began:
			isInteractive = true
//			destinationViewController.performSegueWithIdentifier("b", sender: nil)
			destinationViewController.dismissViewControllerAnimated(true, completion: nil)
		case .Changed:
			self.updateInteractiveTransition(distance)
		default:
			isInteractive = false
			if distance >= 0.7 {
				self.finishInteractiveTransition()
			} else {
				self.cancelInteractiveTransition()
			}
		}
	}
	
	private func offStage(offset: CGFloat) -> CGAffineTransform {
		return CGAffineTransformMakeTranslation(offset, 0)
	}
	
	private func offStageMenuViewControllerTransition(menuViewController: MenuViewController) {
		
		menuViewController.view.alpha = 0.0
		
		let offset: CGFloat = -200
		menuViewController.view.transform = offStage(offset)
	}
	
	private func onStageMenuViewControllerTransition(menuViewController: MenuViewController) {
		
		menuViewController.view.alpha = 1.0
		
		menuViewController.view.transform = CGAffineTransformIdentity
	}
}

extension TransitionDelegate : UIViewControllerAnimatedTransitioning {
	
	public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		if isPresenting {
			return presentingDuration
		} else {
			return dismissingDuration
		}
	}
	
	public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		
		let container = transitionContext.containerView()!
		
		let screen: (from: UIViewController, to: UIViewController) = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!, transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
		
		let menuVC = !isPresenting ? screen.from as! MenuViewController : screen.to as! MenuViewController
		let mainVC = !isPresenting ? screen.to as! ViewController : screen.from as! ViewController
		
		let menuView = menuVC.view
		let mainView = mainVC.view
		
		if isPresenting {
			offStageMenuViewControllerTransition(menuVC)
		}
		
		container.addSubview(menuView)
		container.addSubview(mainView)
		
		let duration = transitionDuration(transitionContext)
		
		UIView.animateWithDuration(duration, animations: { 
			if self.isPresenting {
				mainView.transform = self.offStage(350)
				self.onStageMenuViewControllerTransition(menuVC)
			} else {
				mainView.transform = CGAffineTransformIdentity
				self.offStageMenuViewControllerTransition(menuVC)
			}
			}) { (finished) in
				print(transitionContext.transitionWasCancelled())
				if transitionContext.transitionWasCancelled() {
					transitionContext.completeTransition(false)
					UIApplication.sharedApplication().keyWindow?.addSubview(screen.from.view)
				} else {
					transitionContext.completeTransition(true)
					UIApplication.sharedApplication().keyWindow?.addSubview(screen.to.view)
					if self.isPresenting {
						menuVC.view.addSubview(mainView)
					}
				}
//				if self.isPresenting {
//					transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
//					menuVC.view.addSubview(mainView)
//					if transitionContext.transitionWasCancelled() {
//						container.addSubview(mainView)
//					}
//				} else {
//					transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
//					
//				}
				
//				transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
//				if self.isPresenting {
//					menuVC.view.addSubview(mainView)
//				}
		}
	}
}

extension TransitionDelegate : UIViewControllerTransitioningDelegate {
	
	
	public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		isPresenting = true
		return self
	}
	
	public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		isPresenting = false
		return self
	}
	
	public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return isInteractive ? self : nil
	}
	
	public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return isInteractive ? self : nil
	}
}