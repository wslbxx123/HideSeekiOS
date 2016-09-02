//
//  LoginController.swift
//  HideSeek
//
//  Created by apple on 6/24/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking

class LoginController: UIViewController {
    let HtmlType = "text/html"
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginScrollView: UIScrollView!
    
    var manager: AFHTTPRequestOperationManager!
    var phone: String = ""
    var password: String = ""
    
    @IBAction func loginBtnClicked(sender: AnyObject) {
        let channalId = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.CHANNEL_ID) as! String
        let paramDict = ["phone": phone,
                         "password": password,
                         "channel_id": channalId]
        manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        
        manager.POST(UrlParam.LOGIN_URL,
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
    
    @IBAction func phoneTextChanged(sender: AnyObject) {
        phone = phoneTextField.text!
        
        checkIfLoginEnabled()
    }
    
    @IBAction func passwordTextChanged(sender: AnyObject) {
        password = passwordTextField.text!
        
        checkIfLoginEnabled()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
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
    
    override func viewDidLayoutSubviews() {
        loginScrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 700)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        loginBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        loginBtn.layer.cornerRadius = 5
        loginBtn.layer.masksToBounds = true
        loginScrollView.delaysContentTouches = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func checkIfLoginEnabled() {
        loginBtn.enabled = !phone.isEmpty && !password.isEmpty
    }
    
    func setInfoFromCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            UserCache.instance.setUser(response["result"] as! NSDictionary)
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }
}
