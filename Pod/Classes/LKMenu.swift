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
        public var tintColor:UIColor = UIColor.lightGrayColor()
        public var titleColor:UIColor = UIColor.whiteColor()
        public var tableColor:UIColor = UIColor(white: 1.0, alpha: 0.9)
        public var cellColor:UIColor = UIColor.clearColor()
        public var cellTextColor:UIColor = UIColor.grayColor()
        public var backColor:UIColor = UIColor(white: 0.0, alpha: 0.2)

        public enum BarStyle {
            case Top
            case Bottom
        }
        public var barStyle:BarStyle = .Top

        public enum Position {
            case Top
            case Bottom
        }
        public var position:Position = .Bottom

        public enum Size:CGFloat {
            case Full = 1.0
            case Large = 0.8    // 4 / 5
            case Middle = 0.5  // 1 / 2
            case Small = 0.3    // 1/ 3
        }
        public var size:Size = .Middle

        public init() {
        }
    }
    
    
    class Cell:UITableViewCell {
        
    }
    
    static let sharedMenu = LKMenu()
    
    @IBOutlet weak var backView:UIView!
    @IBOutlet weak var tableView:UITableView!

    @IBOutlet weak var barView1: UIView!
    @IBOutlet weak var barView2: UIView!
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var closeButton1: UIButton!
    @IBOutlet weak var closeButton2: UIButton!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var spacerView: UIView!
    
    @IBOutlet weak var bar1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bar2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var spacerHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var shadowView1: UIView!
    @IBOutlet weak var shadowView2: UIView!
    
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
        
        tableView.registerClass(Cell.self, forCellReuseIdentifier: "Cell")
        
        backView.alpha = 0.0
        let g1 = UITapGestureRecognizer(target: self, action: "onBackView")
        backView.addGestureRecognizer(g1)
        g1.delegate = self

        if appearance.position == .Top && appearance.barStyle == .Bottom {
                barView2.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "pannedOnBar:"))
        } else if appearance.position == .Bottom && appearance.barStyle == .Top {
                barView1.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "pannedOnBar:"))
        }
        
        parentView.addSubview(backView)
        backView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let views = ["backView":backView]
        let hc0 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[backView]-0-|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        parentView.addConstraints(hc0)
        let vc0 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[backView]-0-|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        parentView.addConstraints(vc0)
        
        spacerHeightConstraint.constant = 5.0
        switch appearance.position {
        case .Top:
            backView.removeConstraint(menuViewBottomConstraint)
            bar1HeightConstraint.constant += 22.0                                   // status bar height
            menuViewTopConstraint.constant = 0
            if appearance.barStyle == .Bottom {
                spacerHeightConstraint.constant = 22.0
            }
        case .Bottom:
            backView.removeConstraint(menuViewTopConstraint)
            menuViewBottomConstraint.constant = 0
        }

        if let str = title {
            switch appearance.barStyle {
            case .Top:
                titleLabel1.text = str
                bar2HeightConstraint.constant = 0
                barView2.hidden = true
            case .Bottom:
                titleLabel2.text = str
                bar1HeightConstraint.constant = 0
                barView1.hidden = true
            }
        } else {
            bar1HeightConstraint.constant = 0
            bar2HeightConstraint.constant = 0
            barView1.hidden = true
            barView2.hidden = true
        }
        addDropShadowAtBottom(shadowView1)
        addDropShadowAtTop(shadowView2)
        
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if (touch.view == backView) {
            return true;
        }else{
            return false;
        }
    }
    
    func setupAppearance() {
        barView1.backgroundColor = appearance.tintColor
        barView2.backgroundColor = appearance.tintColor
        titleLabel1.textColor = appearance.titleColor
        titleLabel2.textColor = appearance.titleColor
        closeButton1.tintColor = appearance.titleColor
        closeButton2.tintColor = appearance.titleColor
        Cell.appearance().tintColor = appearance.tintColor
        tableView.backgroundColor = appearance.tableColor
        spacerView.backgroundColor = appearance.tableColor

        backView.backgroundColor = appearance.backColor
    }
    
    func open(parentView:UIView, menuItems:[String], selectedIndex:Int?, title:String?, appearance:Appearance, completion:(result:Result)->Void) {
        
        reset()

        self.appearance = appearance
        self.completion = completion
        self.selectedIndex = selectedIndex
        self.menuItems = menuItems
        
        loadViews(parentView, title:title)
        setupAppearance()

        // opening animation
        menuViewHeightConstraint.constant = 0.0
        backView.layoutIfNeeded()
        
        if let index = selectedIndex {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: .Middle, animated: false)
        }

        menuViewHeightConstraint.constant = parentView.bounds.size.height * appearance.size.rawValue
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.backView.alpha = 1.0
                self.backView.layoutIfNeeded()
        }) { (Bool) -> Void in
            self.opened = true
        }
    }
    
    func close(result:Result, duration:NSTimeInterval = 0.2) {
        completion(result: result)
        menuViewHeightConstraint.constant = 0.0
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.backView.alpha = 0.0
            self.backView.layoutIfNeeded()
        }) { (Bool) -> Void in
            self.reset()
            self.opened = false
        }
    }
    
    func cancel(duration:NSTimeInterval = 0.2) {
        close(.Cancel, duration:duration)
    }

    deinit {
        tableView.removeFromSuperview()
    }
    
    func onBackView() {
        cancel()
    }

    
    // MARK: - API
    public class func open(parentView:UIView, menuItems:[String],
        selectedIndex:Int?=nil, title:String?=nil, appearance:Appearance=Appearance(),
        completion:(result:Result)->Void) {
            sharedMenu.open(parentView, menuItems:menuItems, selectedIndex:selectedIndex, title:title, appearance:appearance, completion:completion)
    }
    public class func close() {
        sharedMenu.cancel()
    }
    public static var opened:Bool {
        return sharedMenu.opened
    }
    
    
    // MARK: - UITableViewDataSource
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! Cell

        cell.textLabel?.text = menuItems[indexPath.row]
        cell.textLabel?.textColor = appearance.cellTextColor
        cell.backgroundColor = appearance.cellColor
        
        if let selectedIndex = self.selectedIndex {
            cell.accessoryType = (selectedIndex == indexPath.row) ? .Checkmark : .None
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        close(.Selected(index: indexPath.row))
    }

    @IBAction func onClose(sender: AnyObject) {
        self.cancel()
    }

    
    // UIScrollViewDelegate
    let VelocityMax = CGFloat(2.3)
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let willClosing:Bool
        switch appearance.position {
        case .Top:
            willClosing = velocity.y > VelocityMax
        case .Bottom:
            willClosing = velocity.y < -VelocityMax
        }
        if  willClosing {
            cancel(duration: 0.4)
        }
    }
    
    // UIPanGestureRecognizer
    var py:CGFloat!
    func pannedOnBar(pgr: UIPanGestureRecognizer) {
        
        let y = pgr.locationInView(backView).y
        switch pgr.state {
        case .Changed:
            menuViewHeightConstraint.constant += (py - y) * (appearance.position == .Top ? -1.0 : 1.0)
            menuView.layoutIfNeeded()
            
        case .Ended:
            if menuViewHeightConstraint.constant < backView.bounds.size.height*Appearance.Size.Small.rawValue {
                cancel(duration: 0.2)
            } else {
                
                if menuViewHeightConstraint.constant < backView.bounds.size.height*(Appearance.Size.Small.rawValue + (Appearance.Size.Middle.rawValue-Appearance.Size.Small.rawValue)/2.0) {
                    menuViewHeightConstraint.constant = backView.bounds.size.height*Appearance.Size.Small.rawValue
                } else if menuViewHeightConstraint.constant < backView.bounds.size.height*(Appearance.Size.Middle.rawValue + (Appearance.Size.Large.rawValue-Appearance.Size.Middle.rawValue)/2.0) {
                    menuViewHeightConstraint.constant = backView.bounds.size.height*Appearance.Size.Middle.rawValue
                } else if menuViewHeightConstraint.constant < backView.bounds.size.height*(Appearance.Size.Large.rawValue + (Appearance.Size.Full.rawValue-Appearance.Size.Large.rawValue)/2.0) {
                    menuViewHeightConstraint.constant = backView.bounds.size.height*Appearance.Size.Large.rawValue
                } else {
                    menuViewHeightConstraint.constant = backView.bounds.size.height*Appearance.Size.Full.rawValue
                }
                shadowView1.hidden = true
                shadowView2.hidden = true
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.menuView.layoutIfNeeded()
                }, completion: { (Bool) -> Void in
                    self.shadowView1.hidden = false
                    self.shadowView2.hidden = false
                })
            }
        default:
            break
        }
        py = y
    }
}

func addDropShadowAtTop(view:UIView) {
    let subLayer = CALayer()
    subLayer.frame = CGRectMake(view.bounds.origin.x, view.bounds.origin.y, 99999.0, view.bounds.size.height)
    view.layer.addSublayer(subLayer)
    subLayer.masksToBounds = true
    let path = UIBezierPath(rect:CGRectMake(-7.5, -7.5, subLayer.bounds.size.width+7.5, 7.5))
    subLayer.shadowOffset = CGSizeMake(2.5, 2.5)
    subLayer.shadowColor = UIColor.blackColor().CGColor
    subLayer.shadowOpacity = 0.2
    subLayer.shadowPath = path.CGPath
}

func addDropShadowAtBottom(view:UIView) {
    let subLayer = CALayer()
    subLayer.frame = CGRectMake(view.bounds.origin.x, view.bounds.origin.y, 99999.0, view.bounds.size.height)
    view.layer.addSublayer(subLayer)
    subLayer.masksToBounds = true
    let path = UIBezierPath(rect:CGRectMake(-7.5, view.bounds.height, subLayer.bounds.size.width+7.5, 7.5))
    subLayer.shadowOffset = CGSizeMake(2.5, -2.5)
    subLayer.shadowColor = UIColor.blackColor().CGColor
    subLayer.shadowOpacity = 0.1
    subLayer.shadowPath = path.CGPath
}