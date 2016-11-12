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
    
    var manager: AFHTTPSessionManager!
    var phone: String = ""
    var verificationCode: String = ""
    var nickname: String = ""
    var password: String = ""
    var rePassword: String = ""
    var countDownTimer: Timer!
    var countDownNum = 30
    
    @IBAction func closeBtnClicked(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendCodeBtnClicked(_ sender: AnyObject) {
        self.sendCodeBtn.isEnabled = false
        self.countDownNum = 30
        
        self.countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RegisterController.timeFireMethod), userInfo: nil, repeats: true)
        
        self.countDownTimer.fire()
        
        SMSSDK.getVerificationCode(by: SMSGetCodeMethodSMS, phoneNumber: phone, zone: "86",
                                           customIdentifier: nil) { (error) in
            if (error == nil) {
                NSLog("发送验证码成功")
            } else {
                NSLog("错误信息：%@", error.debugDescription)
            }
        }
    }
    
    @IBAction func phoneTextChanged(_ sender: AnyObject) {
        phone = phoneTextField.text!
        
        if self.countDownTimer != nil {
            self.countDownTimer.invalidate()
            self.countDownTimer = nil
        }
        
        self.sendCodeBtn.setTitle(
            NSLocalizedString("SEND_VERIFICATION_CODE", comment: "Send Verification Code"),
            for: UIControlState())
        
        checkIfCodeEnabled()
        checkIfRegisterEnabled()
    }
    
    @IBAction func verificationCodeTextChanged(_ sender: AnyObject) {
        verificationCode = codeTextField.text!
        
        checkIfRegisterEnabled()
    }
    
    @IBAction func nicknameTextChanged(_ sender: AnyObject) {
        nickname = nicknameTextField.text!
        
        checkIfRegisterEnabled()
    }
    
    @IBAction func passwordTextChanged(_ sender: AnyObject) {
        password = passwordTextField.text!
        
        checkIfRegisterEnabled()
    }
    
    @IBAction func rePasswordTextChanged(_ sender: AnyObject) {
        rePassword = rePasswordTextField.text!
        
        checkIfRegisterEnabled()
    }
    
    @IBAction func registerBtnClicked(_ sender: AnyObject) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let paramDict = ["phone": phone]
        
        _ = manager.post(UrlParam.CHECK_IF_USER_EXIST_URL,
                         parameters: paramDict,
                         progress: nil,
                         success: { (dataTask, responseObject) in
                            let response = responseObject as! NSDictionary
                            print("JSON: " + responseObject.debugDescription)
                            
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        registerScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 700)
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
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            self.checkVerificationCode();
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
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
        
                let storyboard = UIStoryboard(name:"Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "Upload") as! UploadPhotoController
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
                    type: HudToastFactory.MessageType.error)
                self.codeTextField.text = ""
            }
        }
    }
    
    func checkIfCodeEnabled() {
        sendCodeBtn.isEnabled = !phone.isEmpty && phone.characters.count == 11
    }
    
    func checkIfRegisterEnabled() {
        registerBtn.isEnabled = !phone.isEmpty && !verificationCode.isEmpty && !nickname.isEmpty
                            && !password.isEmpty && !rePassword.isEmpty
    }
    
    func timeFireMethod() {
        if(countDownNum == 0) {
            countDownTimer.invalidate()
            countDownTimer = nil
            self.sendCodeBtn.isEnabled = true
            self.sendCodeBtn.setTitle(
                NSLocalizedString("SEND_VERIFICATION_CODE", comment: "Send Verification Code"),
                for: UIControlState())
        } else {
            self.sendCodeBtn.setTitle("\(countDownNum)s", for: UIControlState())
            countDownNum -= 1
        }
    }
}
