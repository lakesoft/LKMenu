//
//  LKMenu.swift
//  Pods
//
//  Created by Hiroshi Hashiguchi on 2015/06/09.
//
//

import UIKit

open class LKMenu: NSObject,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate {
    
    open class Appearance {
        open var barColor:UIColor = UIColor.lightGray
        open var checkmarkColor:UIColor?
        open var titleColor:UIColor = UIColor.white
        open var tableColor:UIColor?
        open var tableSeparatorColor:UIColor?
        open var cellColor:UIColor?
        open var selectedCellColor:UIColor?
        open var cellTextColor:UIColor?
        open var backColor:UIColor = UIColor(white: 0.0, alpha: 0.2)

        public enum BarStyle {
            case top
            case bottom
        }
        open var barStyle:BarStyle = .top

        public enum Position {
            case top
            case bottom
        }
        open var position:Position = .bottom

        public enum Size:CGFloat {
            case full = 1.0
            case large = 0.8    // 4 / 5
            case middle65 = 0.65
            case middle = 0.5  // 1 / 2
            case small = 0.3    // 1/ 3
        }
        open var size:Size = .middle

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
        case cancel
        case selected(index:Int)
    }
    
    var completion:((_ result:Result)->Void)!

    func reset() {
        if backView != nil {
            backView.removeFromSuperview()
            backView = nil
        }
        self.completion = nil
        self.selectedIndex = nil
        self.menuItems = nil
    }
    
    func loadViews(_ parentView:UIView, title:String?) {
        
        let frameworkBundle = Bundle(for: LKMenu.self)
        let path = frameworkBundle.path(forResource: "LKMenu", ofType: "bundle")!
        let bundle = Bundle(path: path)
        let nib = UINib(nibName: "LKMenu", bundle: bundle)
        nib.instantiate(withOwner: self, options: nil)
        
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        
        backView.alpha = 0.0
        let g1 = UITapGestureRecognizer(target: self, action: #selector(LKMenu.onBackView))
        backView.addGestureRecognizer(g1)
        g1.delegate = self

        if appearance.position == .top && appearance.barStyle == .bottom {
                barView2.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(LKMenu.pannedOnBar(_:))))
        } else if appearance.position == .bottom && appearance.barStyle == .top {
                barView1.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(LKMenu.pannedOnBar(_:))))
        }
        
        parentView.addSubview(backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = ["backView":backView]
        let hc0 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[backView]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        parentView.addConstraints(hc0)
        let vc0 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[backView]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        parentView.addConstraints(vc0)
        
        spacerHeightConstraint.constant = 0.0
        switch appearance.position {
        case .top:
            backView.removeConstraint(menuViewBottomConstraint)
            bar1HeightConstraint.constant += 22.0                                   // status bar height
            menuViewTopConstraint.constant = 0
            if appearance.barStyle == .bottom {
                spacerHeightConstraint.constant = 22.0
            }
        case .bottom:
            backView.removeConstraint(menuViewTopConstraint)
            menuViewBottomConstraint.constant = 0
        }

        if let str = title {
            switch appearance.barStyle {
            case .top:
                titleLabel1.text = str
                bar2HeightConstraint.constant = 0
                barView2.isHidden = true
            case .bottom:
                titleLabel2.text = str
                bar1HeightConstraint.constant = 0
                barView1.isHidden = true
            }
        } else {
            bar1HeightConstraint.constant = 0
            bar2HeightConstraint.constant = 0
            barView1.isHidden = true
            barView2.isHidden = true
        }
        addDropShadowAtBottom(shadowView1)
        addDropShadowAtTop(shadowView2)
        
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view == backView) {
            return true;
        }else{
            return false;
        }
    }
    
    func setupAppearance() {
        barView1.backgroundColor = appearance.barColor
        barView2.backgroundColor = appearance.barColor
        titleLabel1.textColor = appearance.titleColor
        titleLabel2.textColor = appearance.titleColor
        closeButton1.tintColor = appearance.titleColor
        closeButton2.tintColor = appearance.titleColor
        if let color = appearance.checkmarkColor {
            Cell.appearance().tintColor = color
        }
        if let color = appearance.tableColor {
            tableView.backgroundColor = color
        } else {
            tableView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        }
        if let color = appearance.tableSeparatorColor {
            tableView.separatorColor = color
            
        }
        spacerView.backgroundColor = appearance.tableColor

        backView.backgroundColor = appearance.backColor
    }
    
    func open(_ parentView:UIView, menuItems:[String], selectedIndex:Int?, title:String?, appearance:Appearance, completion:@escaping (_ result:Result)->Void) {
        
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
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
        }

        menuViewHeightConstraint.constant = parentView.bounds.size.height * appearance.size.rawValue
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.0, options: UIView.AnimationOptions(),
            animations: { () -> Void in
                self.backView.alpha = 1.0
                self.backView.layoutIfNeeded()
        }) { (Bool) -> Void in
            self.opened = true
        }
    }
    
    func close(_ result:Result, duration:TimeInterval = 0.2) {
        completion(result)
        menuViewHeightConstraint.constant = 0.0
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.backView.alpha = 0.0
            self.backView.layoutIfNeeded()
        }, completion: { (Bool) -> Void in
            self.reset()
            self.opened = false
        }) 
    }
    
    func cancel(_ duration:TimeInterval = 0.2) {
        close(.cancel, duration:duration)
    }

    deinit {
        tableView.removeFromSuperview()
    }
    
    @objc func onBackView() {
        cancel()
    }

    
    // MARK: - API
    open class func open(_ parentView:UIView, menuItems:[String],
        selectedIndex:Int?=nil, title:String?=nil, appearance:Appearance=Appearance(),
        completion:@escaping (_ result:Result)->Void) {
            sharedMenu.open(parentView, menuItems:menuItems, selectedIndex:selectedIndex, title:title, appearance:appearance, completion:completion)
    }
    open class func close() {
        sharedMenu.cancel()
    }
    public static var opened:Bool {
        return sharedMenu.opened
    }
    
    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell

        cell.textLabel?.text = menuItems[indexPath.row]
        if let color = appearance.cellTextColor {
            cell.textLabel?.textColor = color
        }
        if let color = appearance.cellColor {
            cell.backgroundColor = color
        }
        if let color = appearance.selectedCellColor {
            cell.selectedBackgroundView = UIView()
            cell.selectedBackgroundView!.backgroundColor = color
        }
        if let selectedIndex = self.selectedIndex {
            cell.accessoryType = (selectedIndex == indexPath.row) ? .checkmark : .none
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        close(.selected(index: indexPath.row))
    }

    @IBAction func onClose(_ sender: AnyObject) {
        self.cancel()
    }

    
    // UIScrollViewDelegate
    let VelocityMax = CGFloat(2.3)
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let willClosing:Bool
        switch appearance.position {
        case .top:
            willClosing = velocity.y > VelocityMax
        case .bottom:
            willClosing = velocity.y < -VelocityMax
        }
        if  willClosing {
            cancel(0.4)
        }
    }
    
    // UIPanGestureRecognizer
    var py:CGFloat!
    @objc func pannedOnBar(_ pgr: UIPanGestureRecognizer) {
        
        let y = pgr.location(in: backView).y
        switch pgr.state {
        case .changed:
            menuViewHeightConstraint.constant += (py - y) * (appearance.position == .top ? -1.0 : 1.0)
            menuView.layoutIfNeeded()
            
        case .ended:
            if menuViewHeightConstraint.constant < backView.bounds.size.height*Appearance.Size.small.rawValue {
                cancel(0.2)
            } else {
                
                if menuViewHeightConstraint.constant < backView.bounds.size.height*(Appearance.Size.small.rawValue + (Appearance.Size.middle.rawValue-Appearance.Size.small.rawValue)/2.0) {
                    menuViewHeightConstraint.constant = backView.bounds.size.height*Appearance.Size.small.rawValue
                } else if menuViewHeightConstraint.constant < backView.bounds.size.height*(Appearance.Size.middle.rawValue + (Appearance.Size.large.rawValue-Appearance.Size.middle.rawValue)/2.0) {
                    menuViewHeightConstraint.constant = backView.bounds.size.height*Appearance.Size.middle.rawValue
                } else if menuViewHeightConstraint.constant < backView.bounds.size.height*(Appearance.Size.large.rawValue + (Appearance.Size.full.rawValue-Appearance.Size.large.rawValue)/2.0) {
                    menuViewHeightConstraint.constant = backView.bounds.size.height*Appearance.Size.large.rawValue
                } else {
                    menuViewHeightConstraint.constant = backView.bounds.size.height*Appearance.Size.full.rawValue
                }
                shadowView1.isHidden = true
                shadowView2.isHidden = true
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.menuView.layoutIfNeeded()
                }, completion: { (Bool) -> Void in
                    self.shadowView1.isHidden = false
                    self.shadowView2.isHidden = false
                })
            }
        default:
            break
        }
        py = y
    }
}

func addDropShadowAtTop(_ view:UIView) {
    let subLayer = CALayer()
    subLayer.frame = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y, width: 99999.0, height: view.bounds.size.height)
    view.layer.addSublayer(subLayer)
    subLayer.masksToBounds = true
    let path = UIBezierPath(rect:CGRect(x: -7.5, y: -7.5, width: subLayer.bounds.size.width+7.5, height: 7.5))
    subLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
    subLayer.shadowColor = UIColor.black.cgColor
    subLayer.shadowOpacity = 0.2
    subLayer.shadowPath = path.cgPath
}

func addDropShadowAtBottom(_ view:UIView) {
    let subLayer = CALayer()
    subLayer.frame = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y, width: 99999.0, height: view.bounds.size.height)
    view.layer.addSublayer(subLayer)
    subLayer.masksToBounds = true
    let path = UIBezierPath(rect:CGRect(x: -7.5, y: view.bounds.height, width: subLayer.bounds.size.width+7.5, height: 7.5))
    subLayer.shadowOffset = CGSize(width: 2.5, height: -2.5)
    subLayer.shadowColor = UIColor.black.cgColor
    subLayer.shadowOpacity = 0.1
    subLayer.shadowPath = path.cgPath
}
