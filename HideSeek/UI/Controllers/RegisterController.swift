//
//  RegisterController.swift
//  HideSeek
//
//  Created by apple on 7/26/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class RegisterController: UIViewController {
    let HtmlType = "text/html"
    @IBOutlet weak var sendCodeBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    @IBOutlet weak var registerScrollView: UIScrollView!
    
    var manager: AFHTTPRequestOperationManager!
    var phone: String = ""
    var verificationCode: String = ""
    var nickname: String = ""
    var password: String = ""
    var rePassword: String = ""
    var countDownTimer: NSTimer!
    var countDownNum = 30
    
    @IBAction func closeBtnClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func sendCodeBtnClicked(sender: AnyObject) {
        self.sendCodeBtn.enabled = false
        self.countDownNum = 30
        
        self.countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(RegisterController.timeFireMethod), userInfo: nil, repeats: true)
        
        self.countDownTimer.fire()
        
        SMSSDK.getVerificationCodeByMethod(SMSGetCodeMethodSMS, phoneNumber: phone, zone: "86",
                                           customIdentifier: nil) { (error) in
            if (error == nil) {
                
            } else {
                NSLog("错误信息：%@", error)
            }
        }
    }
    
    @IBAction func phoneTextChanged(sender: AnyObject) {
        phone = phoneTextField.text!
        
        checkIfCodeEnabled()
        checkIfRegisterEnabled()
    }
    
    @IBAction func verificationCodeTextChanged(sender: AnyObject) {
        verificationCode = codeTextField.text!
        
        checkIfRegisterEnabled()
    }
    
    @IBAction func nicknameTextChanged(sender: AnyObject) {
        nickname = nicknameTextField.text!
        
        checkIfRegisterEnabled()
    }
    
    @IBAction func passwordTextChanged(sender: AnyObject) {
        password = passwordTextField.text!
        
        checkIfRegisterEnabled()
    }
    
    @IBAction func rePasswordTextChanged(sender: AnyObject) {
        rePassword = rePasswordTextField.text!
        
        checkIfRegisterEnabled()
    }
    
    @IBAction func registerBtnClicked(sender: AnyObject) {
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        
        let paramDict = ["phone": phone]
        
        manager.POST(UrlParam.CHECK_IF_USER_EXIST,
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        registerScrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 700)
    }

    func initView() {
        sendCodeBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        sendCodeBtn.layer.cornerRadius = 5
        sendCodeBtn.layer.masksToBounds = true
        
        registerBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        registerBtn.layer.cornerRadius = 5
        registerBtn.layer.masksToBounds = true
        
        registerScrollView.delaysContentTouches = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func setInfoFromCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            self.checkVerificationCode();
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }
    
    func checkVerificationCode() {
        SMSSDK.commitVerificationCode(self.verificationCode, phoneNumber: phone, zone: "86") { (error) in
            if ((error == nil)) {
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
        
                let storyboard = UIStoryboard(name:"Main", bundle: nil)
                let viewController = storyboard.instantiateViewControllerWithIdentifier("Upload") as! UploadPhotoController
                viewController.phone = self.phone
                viewController.nickname = self.nickname
                viewController.password = self.password
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else
            {
                HudToastFactory.show(
                    NSLocalizedString("ERROR_VERIFICATION_CODE",
                        comment: "The input verification code is wrong"),
                    view: self.view,
                    type: HudToastFactory.MessageType.ERROR)
                self.codeTextField.text = ""
            }
        }
    }
    
    func checkIfCodeEnabled() {
        sendCodeBtn.enabled = !phone.isEmpty && phone.characters.count == 11
    }
    
    func checkIfRegisterEnabled() {
        registerBtn.enabled = !phone.isEmpty && !verificationCode.isEmpty && !nickname.isEmpty
                            && !password.isEmpty && !rePassword.isEmpty
    }
    
    func timeFireMethod() {
        if(countDownNum == 0) {
            countDownTimer.invalidate()
            countDownTimer = nil
            self.sendCodeBtn.enabled = true
            self.sendCodeBtn.setTitle(
                NSLocalizedString("SEND_VERIFICATION_CODE", comment: "Send Verification Code"),
                forState: UIControlState.Normal)
        } else {
            self.sendCodeBtn.setTitle("\(countDownNum)s", forState: UIControlState.Normal)
            countDownNum -= 1
        }
    }
}
