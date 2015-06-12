//
//  ViewController.swift
//  LKMenu
//
//  Created by Hiroshi Hashiguchi on 06/09/2015.
//  Copyright (c) 06/09/2015 Hiroshi Hashiguchi. All rights reserved.
//

import UIKit
import LKMenu

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onOpen(sender: AnyObject) {
        LKMenu.open(self.view, menuItems:["AA", "BB", "CC", "DD"], selectedIndex:2, title:"Menu Sample") { result in
            switch result {
            case .Cancel:
                println("canceled")
            case .Selected(let index):
                println("selected: \(index)")
            }
        }
    }
}

