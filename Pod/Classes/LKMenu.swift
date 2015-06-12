//
//  LKMenu.swift
//  Pods
//
//  Created by Hiroshi Hashiguchi on 2015/06/09.
//
//

import UIKit

public class LKMenu: NSObject,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate {
    
    public class Appearance {
        var tintColor:UIColor = UIColor.lightGrayColor()
        var titleColor:UIColor = UIColor.whiteColor()
        var tableColor:UIColor = UIColor.whiteColor()
        var cellTextColor:UIColor = UIColor.grayColor()
    }
    
    class MenuItemCell:UITableViewCell {
        
    }
    
    static let sharedMenu = LKMenu()
    
    @IBOutlet weak var backView:UIView!
    @IBOutlet weak var tableView:UITableView!

    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var barHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!

    var appearance:Appearance!
    var opened: Bool = false
    
    var selectedIndex:Int?
    var menuItems: [String]!

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
        self.completion = nil
        self.selectedIndex = nil
        self.menuItems = nil
    }
    
    func loadViews(parentView:UIView, title:String?) {
        
        let frameworkBundle = NSBundle(forClass: LKMenu.self)
        let path = frameworkBundle.pathForResource("LKMenu", ofType: "bundle")!
        let bundle = NSBundle(path: path)
        let nib = UINib(nibName: "LKMenu", bundle: bundle)
        nib.instantiateWithOwner(self, options: nil)
        
        backView.alpha = 0.0
        let g1 = UITapGestureRecognizer(target: self, action: "onBackView")
        backView.addGestureRecognizer(g1)
        g1.delegate = self

        barView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBackView"))
        
        parentView.addSubview(backView)
        backView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let views = ["backView":backView]
        let hc0 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[backView]-0-|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        parentView.addConstraints(hc0)
        let vc0 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[backView]-0-|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        parentView.addConstraints(vc0)
        
        if let str = title {
            titleLabel.text = str
        } else {
            titleLabel.text = ""
            barHeightConstraint.constant = 0
        }
        
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if (touch.view == backView) {
            return true;
        }else{
            return false;
        }
    }
    
    func setupAppearance() {
        barView.backgroundColor = appearance.tintColor
        titleLabel.textColor = appearance.titleColor
        MenuItemCell.appearance().tintColor = appearance.tintColor
    }
    
    func open(parentView:UIView, menuItems:[String], selectedIndex:Int?, title:String?, appearance:Appearance, completion:(result:Result)->Void) {
        
        reset()

        self.appearance = appearance
        self.completion = completion
        self.selectedIndex = selectedIndex
        self.menuItems = menuItems
        
        opened = true

        loadViews(parentView, title:title)
        setupAppearance()

        // opening animation
        tableHeightConstraint.constant = 0.0
        parentView.layoutIfNeeded()

        tableHeightConstraint.constant = 240.0
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.backView.alpha = 1.0
                parentView.layoutIfNeeded()
        }) { (Bool) -> Void in
        }
    }
    
    func close(duration:NSTimeInterval = 0.2) {
        tableHeightConstraint.constant = 0.0
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.backView.alpha = 0.0
            self.backView.layoutIfNeeded()
//            self.parentView.layoutIfNeeded()
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
    public class func open(parentView:UIView, menuItems:[String],
        selectedIndex:Int?=nil, title:String?=nil, appearance:Appearance=Appearance(),
        completion:(result:Result)->Void) {
            sharedMenu.open(parentView, menuItems:menuItems, selectedIndex:selectedIndex, title:title, appearance:appearance, completion:completion)
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
        let cell = MenuItemCell(style: .Default, reuseIdentifier: "MenuItemCell")

        cell.textLabel?.text = menuItems[indexPath.row]
        cell.textLabel?.textColor = appearance.cellTextColor
        
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