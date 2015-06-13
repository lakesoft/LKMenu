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

    func open(appearance:LKMenu.Appearance) {
        LKMenu.open(self.view, menuItems:["AA", "BB", "CC", "DD", "EE", "FF", "GG", "HH"], selectedIndex:0, appearance:appearance, title:"Menu Sample") { result in
            switch result {
            case .Cancel:
                println("canceled")
            case .Selected(let index):
                println("selected: \(index)")
            }
        }
    }
    
    
    @IBAction func onTopMenuTopBar(sender: AnyObject) {
        var appearance = LKMenu.Appearance()
        appearance.position = .Top
        appearance.barStyle = .Top
        appearance.size = .Large
        open(appearance)
    }

    @IBAction func onTopMenuBottomBar(sender: AnyObject) {
        var appearance = LKMenu.Appearance()
        appearance.position = .Top
        appearance.barStyle = .Bottom
        open(appearance)
    }

    @IBAction func onBottomMenuTopBar(sender: AnyObject) {
        var appearance = LKMenu.Appearance()
        appearance.position = .Bottom
        appearance.barStyle = .Top
        open(appearance)
    }

    @IBAction func onBottomMenuBottomBar(sender: AnyObject) {
        var appearance = LKMenu.Appearance()
        appearance.position = .Bottom
        appearance.barStyle = .Bottom
        appearance.size = .Large
        open(appearance)
    }

}

