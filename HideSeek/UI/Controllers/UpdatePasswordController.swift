//
//  UpdatePasswordController.swift
//  HideSeek
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking

class UpdatePasswordController: UIViewController {
    let HtmlType = "text/html"
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    @IBOutlet weak var updatePasswordScrollView: UIScrollView!
    
    var manager: AFHTTPRequestOperationManager!
    var phone: String!
    var password: String = ""
    var rePassword: String = ""
    
    @IBAction func closeBtnClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func passwordChanged(sender: AnyObject) {
        password = passwordTextField.text!
        
        checkIfSaveBtnEnabled()
    }
    
    @IBAction func rePasswordChanged(sender: AnyObject) {
        rePassword = rePasswordTextField.text!
        
        checkIfSaveBtnEnabled()
    }
    
    @IBAction func saveBtnClicked(sender: AnyObject) {
        if self.password != self.rePassword {
            HudToastFactory.show(
                NSLocalizedString("ERROR_PASSWORD_NOT_SAME",
                    comment: "Two passwords are not the same"),
                view: self.view,
                type: HudToastFactory.MessageType.ERROR)
            return
        }
        
        if self.password.characters.count < 6 {
            HudToastFactory.show(
                NSLocalizedString("ERROR_PASSWORD_SHORT",
                    comment: "The password is too short"),
                view: self.view,
                type: HudToastFactory.MessageType.ERROR)
            return
        }
        
        if self.password.characters.count > 45 {
            HudToastFactory.show(
                NSLocalizedString("ERROR_PASSWORD_LONG",
                    comment: "The length of password cannot be greater than 45"),
                view: self.view,
                type: HudToastFactory.MessageType.ERROR)
            return
        }
        
        savePassword()
    }
    
    func savePassword() {
        let paramDict = ["phone": phone,
                         "password": password]
        
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        
        manager.POST(UrlParam.UPDATE_PASSWORD_URL,
                     parameters: paramDict,
                     success: { (operation, responseObject) in
                        let response = responseObject as! NSDictionary
                        print("JSON: " + responseObject.description!)
                        self.setInfoFromCallback(response)
                        
                        hud.removeFromSuperview()
                        hud = nil
            },
                     failure: { (operation, error) in
                        print("Error: " + error.localizedDescription)
                        let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
                        HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
                        hud.removeFromSuperview()
                        hud = nil
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        
        super.viewWillDisappear(animated)
    }
    
    func initView() {
        saveBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        saveBtn.layer.cornerRadius = 5
        saveBtn.layer.masksToBounds = true
        updatePasswordScrollView.delaysContentTouches = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func checkIfSaveBtnEnabled() {
        saveBtn.enabled = !password.isEmpty && !rePassword.isEmpty
    }
    
    func setInfoFromCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            let alertController = UIAlertController(title: nil,
                                                    message: NSLocalizedString("SUCCESS_UPDATE_PASSWORD", comment: "Update password successfully"), preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                                         style: UIAlertActionStyle.Default, handler: { (action) in
                                            self.navigationController?.popToRootViewControllerAnimated(true)
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }

}
