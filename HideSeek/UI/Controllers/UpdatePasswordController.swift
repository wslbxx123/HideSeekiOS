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
    
    var manager: AFHTTPSessionManager!
    var phone: String!
    var password: String = ""
    var rePassword: String = ""
    
    @IBAction func closeBtnClicked(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func passwordChanged(_ sender: AnyObject) {
        password = passwordTextField.text!
        
        checkIfSaveBtnEnabled()
    }
    
    @IBAction func rePasswordChanged(_ sender: AnyObject) {
        rePassword = rePasswordTextField.text!
        
        checkIfSaveBtnEnabled()
    }
    
    @IBAction func saveBtnClicked(_ sender: AnyObject) {
        if self.password != self.rePassword {
            HudToastFactory.show(
                NSLocalizedString("ERROR_PASSWORD_NOT_SAME",
                    comment: "Two passwords are not the same"),
                view: self.view,
                type: HudToastFactory.MessageType.error)
            return
        }
        
        if self.password.characters.count < 6 {
            HudToastFactory.show(
                NSLocalizedString("ERROR_PASSWORD_SHORT",
                    comment: "The password is too short"),
                view: self.view,
                type: HudToastFactory.MessageType.error)
            return
        }
        
        if self.password.characters.count > 45 {
            HudToastFactory.show(
                NSLocalizedString("ERROR_PASSWORD_LONG",
                    comment: "The length of password cannot be greater than 45"),
                view: self.view,
                type: HudToastFactory.MessageType.error)
            return
        }
        
        savePassword()
    }
    
    func savePassword() {
        let paramDict = ["phone": phone,
                         "password": password]
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        _ = manager.post(UrlParam.UPDATE_PASSWORD_URL,
                         parameters: paramDict,
                         progress: nil, success: { (dataTask, responseObject) in
                            let response = responseObject as! NSDictionary
                            print("JSON: " + (responseObject as AnyObject).description!)
                            self.setInfoFromCallback(response)
                            
                            hud.removeFromSuperview()
                            
            }, failure: { (dataTask, error) in
                print("Error: " + error.localizedDescription)
                let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
                hud.removeFromSuperview()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
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
        saveBtn.isEnabled = !password.isEmpty && !rePassword.isEmpty
    }
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let alertController = UIAlertController(title: nil,
                                                    message: NSLocalizedString("SUCCESS_UPDATE_PASSWORD", comment: "Update password successfully"), preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                                         style: UIAlertActionStyle.default, handler: { (action) in
                                            _ = self.navigationController?.popToRootViewController(animated: true)
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
        }
    }

}
