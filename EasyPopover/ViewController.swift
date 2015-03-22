//
//  ViewController.swift
//  EasyPopover
//
//  Created by 程巍巍 on 3/21/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func showPopover(sender: UIButton) {
        
        var view = UIView(frame: CGRectMake(0, 0, CGFloat(arc4random()%1000), CGFloat(arc4random()%1000)))
//        var view = UIView(frame: CGRectMake(0, 0, 200, 100))
        view.backgroundColor = UIColor.blackColor()
        
        EasyPopover(contentView: view).popFromRect(sender.frame, inView: self.view)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

