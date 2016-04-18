//
//  ViewController.swift
//  PercentageTranition
//
//  Created by David on 2016/4/17.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	let tranitionDelegate = TransitionDelegate()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.tranitionDelegate.sourceViewController = self
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let vc = segue.destinationViewController as! MenuViewController
		self.tranitionDelegate.destinationViewController = vc
		vc.transitioningDelegate = self.tranitionDelegate
	}

	@IBAction func unwindToMainViewController(sender: UIStoryboardSegue) {
		dismissViewControllerAnimated(true, completion: nil)
	}
}

