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
    
    var manager: AFHTTPSessionManager!
    var phone: String = ""
    var password: String = ""
    
    @IBAction func closeBtnClicked(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginBtnClicked(_ sender: AnyObject) {
        let channalId = UserDefaults.standard.object(forKey: UserDefaultParam.CHANNEL_ID) as? String
        
        let paramDict = ["phone": phone,
                         "password": password,
                         "channel_id": channalId == nil ? "" : channalId!,
                         "app_platform": "0"]
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        _ = manager.post(UrlParam.LOGIN_URL,
                         parameters: paramDict,
                         progress: nil,
                         success: { (dataTask, responseObject) in
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
    
    @IBAction func phoneTextChanged(_ sender: AnyObject) {
        phone = phoneTextField.text!
        
        checkIfLoginEnabled()
    }
    
    @IBAction func passwordTextChanged(_ sender: AnyObject) {
        password = passwordTextField.text!
        
        checkIfLoginEnabled()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
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
    
    override func viewDidLayoutSubviews() {
        loginScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 700)
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
        loginBtn.isEnabled = !phone.isEmpty && !password.isEmpty
    }
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"] as AnyObject)
        if code == CodeParam.SUCCESS {
            UserCache.instance.setUser(response["result"] as! NSDictionary)
            
            PushManager.instance.register()
            GoalCache.instance.ifNeedClearMap = true
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
        }
    }
}
