//
//  RegionController.swift
//  HideSeek
//
//  Created by apple on 7/28/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import MBProgressHUD

class RegionController: UIViewController, SelectRegionDelegate, ShowToastDelegate {
    @IBOutlet weak var internalBtn: UIButton!
    @IBOutlet weak var externalBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    var internalController: InternalController!
    var externalController: ExternalController!
    
    @IBAction func backBtnClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        self.internalController = nil
        self.externalController = nil
    }
    
    @IBAction func internalBtnClicked(sender: AnyObject) {
        showInternal()
    }
    
    @IBAction func externalBtnClicked(sender: AnyObject) {
        internalBtn.selected = false
        externalBtn.selected = true
        
        self.addChildViewController(externalController)
        contentView.addSubview(externalController.view)
        
        internalController.removeFromParentViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        internalBtn.setImageUpTitleDown()
        externalBtn.setImageUpTitleDown()
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        internalController = storyboard.instantiateViewControllerWithIdentifier("internal") as! InternalController
        externalController = storyboard.instantiateViewControllerWithIdentifier("external") as! ExternalController
        internalController.selectRegionDelegate = self
        externalController.selectRegionDelegate = self
        internalController.showToastDelegate = self
        externalController.showToastDelegate = self
        
        internalController.view.layer.frame = CGRectMake(
            internalController.view.layer.frame.minX,
            internalController.view.layer.frame.minY,
            internalController.view.layer.frame.width,
            internalController.view.layer.frame.height - 120)
        externalController.view.layer.frame = CGRectMake(
            externalController.view.layer.frame.minX,
            externalController.view.layer.frame.minY,
            externalController.view.layer.frame.width,
            externalController.view.layer.frame.height - 120)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showInternal()
        self.navigationController?.navigationBarHidden = false
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInternal() {
        internalBtn.selected = true
        externalBtn.selected = false
        
        self.addChildViewController(internalController)
        contentView.addSubview(internalController.view)
        
        externalController.removeFromParentViewController()
    }
    
    func regionSelected(name: String) {
        self.navigationController?.popViewControllerAnimated(true)
        self.internalController = nil
        self.externalController = nil
        self.closure(name: name)
    }
    
    typealias Closure = (name: String) ->Void
    var closure: Closure!
    
    func callBack(closure: Closure!) {
        self.closure = closure
    }
    
    func showToast(text: String) {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = text
        hud.labelFont = UIFont.systemFontOfSize(30)
        hud.labelColor = UIColor.whiteColor()
        hud.cornerRadius = 0
        hud.mode = MBProgressHUDMode.Text
        hud.userInteractionEnabled = false
        hud.removeFromSuperViewOnHide = true;
        hud.hide(true, afterDelay: 1)
    }
}
