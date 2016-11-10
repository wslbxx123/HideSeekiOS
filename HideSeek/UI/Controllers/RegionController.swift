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
    
    @IBAction func backBtnClicked(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
        self.internalController = nil
        self.externalController = nil
    }
    
    @IBAction func internalBtnClicked(_ sender: AnyObject) {
        showInternal()
    }
    
    @IBAction func externalBtnClicked(_ sender: AnyObject) {
        internalBtn.isSelected = false
        externalBtn.isSelected = true
        
        self.addChildViewController(externalController)
        contentView.addSubview(externalController.view)
        
        internalController.removeFromParentViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        internalBtn.setImageUpTitleDown()
        externalBtn.setImageUpTitleDown()
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        internalController = storyboard.instantiateViewController(withIdentifier: "internal") as! InternalController
        externalController = storyboard.instantiateViewController(withIdentifier: "external") as! ExternalController
        internalController.selectRegionDelegate = self
        externalController.selectRegionDelegate = self
        internalController.showToastDelegate = self
        externalController.showToastDelegate = self
        
        internalController.view.layer.frame = CGRect(
            x: internalController.view.layer.frame.minX,
            y: internalController.view.layer.frame.minY,
            width: internalController.view.layer.frame.width,
            height: internalController.view.layer.frame.height - 120)
        externalController.view.layer.frame = CGRect(
            x: externalController.view.layer.frame.minX,
            y: externalController.view.layer.frame.minY,
            width: externalController.view.layer.frame.width,
            height: externalController.view.layer.frame.height - 120)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showInternal()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInternal() {
        internalBtn.isSelected = true
        externalBtn.isSelected = false
        
        self.addChildViewController(internalController)
        contentView.addSubview(internalController.view)
        
        externalController.removeFromParentViewController()
    }
    
    func regionSelected(_ name: String) {
        self.navigationController?.popViewController(animated: true)
        self.internalController = nil
        self.externalController = nil
        self.closure(name)
    }
    
    typealias Closure = (_ name: String) ->Void
    var closure: Closure!
    
    func callBack(_ closure: Closure!) {
        self.closure = closure
    }
    
    func showToast(_ text: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.labelText = text
        hud.labelFont = UIFont.systemFont(ofSize: 30)
        hud.labelColor = UIColor.white
        hud.cornerRadius = 0
        hud.mode = MBProgressHUDMode.text
        hud.isUserInteractionEnabled = false
        hud.removeFromSuperViewOnHide = true;
        hud.hide(true, afterDelay: 1)
    }
}
