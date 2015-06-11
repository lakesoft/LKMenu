//
//  LKMenu.swift
//  Pods
//
//  Created by Hiroshi Hashiguchi on 2015/06/09.
//
//

import UIKit

public class LKMenu: NSObject,UITableViewDataSource,UITableViewDelegate {
    
    static let sharedMenu = LKMenu()
    
    var backView:UIView!
    var tableView:UITableView!
    var v1c: NSLayoutConstraint!

    var opened: Bool = false
    
    var selectedIndex:Int?
    var menuItems: [String]!

    weak var parentView:UIView!
    
    public enum Result {
        case Cancel
        case Selected(index:Int)
    }
    
    var completion:((result:Result)->Void)!

    func reset() {
        if backView != nil {
            backView.removeFromSuperview()
            backView = nil
        }
        if tableView != nil {
            tableView.removeFromSuperview()
            tableView = nil
        }
        self.v1c = nil
        self.parentView = nil
        self.completion = nil
        self.selectedIndex = nil
        self.menuItems = nil
    }
    
    func addBackView(parentView:UIView) {
        backView = UIView()
        backView.alpha = 0.0
        backView.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBackView"))
        
        parentView.addSubview(backView)
        backView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let views = ["backView":backView]
        let hc0 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[backView]-0-|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        parentView.addConstraints(hc0)
        let vc0 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[backView]-0-|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        parentView.addConstraints(vc0)
    }
    
    func addTableView(parentView:UIView) {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        parentView.addSubview(tableView)
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let h1c = NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal,
            toItem: parentView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        parentView.addConstraint(h1c)
        let h2c = NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal,
            toItem: parentView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        parentView.addConstraint(h2c)
        
        let v1c = NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal,
            toItem: parentView, attribute: .CenterY, multiplier: 1.0, constant: parentView.frame.size.height)
        parentView.addConstraint(v1c)
        let v2c = NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal,
            toItem: parentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        v2c.priority = 750
        parentView.addConstraint(v2c)

        self.v1c = v1c  // not good code
    }
    
    func open(parentView:UIView, menuItems:[String], selectedIndex:Int?, completion:(result:Result)->Void) {
        
        reset()

        self.parentView = parentView
        self.completion = completion
        self.selectedIndex = selectedIndex
        self.menuItems = menuItems
        
        opened = true

        addBackView(parentView)
        addTableView(parentView)

        parentView.layoutIfNeeded()
        
        v1c.constant = 0.0
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.backView.alpha = 1.0
                parentView.layoutIfNeeded()
        }) { (Bool) -> Void in
        }
    }
    
    func close(duration:NSTimeInterval = 0.2) {
        v1c.constant = parentView.frame.size.height
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.backView.alpha = 0.0
            self.parentView.layoutIfNeeded()
        }) { (Bool) -> Void in
            self.reset()
            self.opened = false
        }
    }

    deinit {
        tableView.removeFromSuperview()
    }
    
    func onBackView() {
        completion(result:.Cancel)
        close()
    }

    
    // MARK: - API
    public class func open(parentView:UIView, menuItems:[String], selectedIndex:Int?=nil, completion:(result:Result)->Void) {
        sharedMenu.open(parentView, menuItems:menuItems, selectedIndex:selectedIndex, completion:completion)
    }
    public class func close() {
        sharedMenu.close()
    }
    public static var opened:Bool {
        return sharedMenu.opened
    }
    
    
    // MARK: - UITableViewDataSource
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "LKMenuControllerCell")

        cell.textLabel?.text = menuItems[indexPath.row]
        
        if let selectedIndex = self.selectedIndex {
            cell.accessoryType = (selectedIndex == indexPath.row) ? .Checkmark : .None
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        completion(result:.Selected(index: indexPath.row))
        close()
    }

    // close by dragging down
    let PulldownMargin = CGFloat(80.0)
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -PulldownMargin {
            completion(result:.Cancel)
            close(duration: 0.4)
        }
    }
}