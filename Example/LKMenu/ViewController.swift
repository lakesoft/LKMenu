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

    func open(_ appearance:LKMenu.Appearance) {
        appearance.selectedCellColor = UIColor.red
        LKMenu.open(self.view, menuItems:["AA", "BB", "CC", "DD", "EE", "FF", "GG", "HH"], selectedIndex:0, title:"Menu Sample", appearance:appearance) { result in
            switch result {
            case .cancel:
                print("canceled")
            case .selected(let index):
                print("selected: \(index)")
            }
        }
    }
    
    
    @IBAction func onTopMenuTopBar(_ sender: AnyObject) {
        let appearance = LKMenu.Appearance()
        appearance.position = .top
        appearance.barStyle = .top
        appearance.size = .large
        open(appearance)
    }

    @IBAction func onTopMenuBottomBar(_ sender: AnyObject) {
        let appearance = LKMenu.Appearance()
        appearance.position = .top
        appearance.barStyle = .bottom
        open(appearance)
    }

    @IBAction func onBottomMenuTopBar(_ sender: AnyObject) {
        let appearance = LKMenu.Appearance()
        appearance.position = .bottom
        appearance.barStyle = .top
        open(appearance)
    }

    @IBAction func onBottomMenuBottomBar(_ sender: AnyObject) {
        let appearance = LKMenu.Appearance()
        appearance.position = .bottom
        appearance.barStyle = .bottom
        appearance.size = .large
        open(appearance)
    }

}

