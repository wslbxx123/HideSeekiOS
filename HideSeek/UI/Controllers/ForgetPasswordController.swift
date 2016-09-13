//
//  ForgetPasswordController.swift
//  HideSeek
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class ForgetPasswordController: UIViewController {
    @IBOutlet weak var nextStepBtn: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var sendCodeBtn: UIButton!
    @IBOutlet weak var forgetPasswordScrollView: UIScrollView!
    
    var phone: String = ""
    var code: String = ""
    var countDownTimer: NSTimer!
    var countDownNum = 30

    @IBAction func closeBtnClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func nextStepBtnClicked(sender: AnyObject) {
        checkVerificationCode()
    }
    
    @IBAction func phoneChanged(sender: AnyObject) {
        phone = phoneTextField.text!
        
        checkIfNextStepEnabled()
        checkIfCodeEnabled()
    }
    
    @IBAction func codeChanged(sender: AnyObject) {
        code = codeTextField.text!
        
        checkIfNextStepEnabled()
    }
    
    @IBAction func sendCodeBtnClicked(sender: AnyObject) {
        self.sendCodeBtn.enabled = false
        self.countDownNum = 30
        
        self.countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ForgetPasswordController.timeFireMethod), userInfo: nil, repeats: true)
        
        self.countDownTimer.fire()
        
        SMSSDK.getVerificationCodeByMethod(SMSGetCodeMethodSMS, phoneNumber: phone, zone: "86",
                                           customIdentifier: nil) { (error) in
                                            if (error == nil) {
                                                
                                            } else {
                                                NSLog("错误信息：%@", error)
                                            }
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        nextStepBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        nextStepBtn.layer.cornerRadius = 5
        nextStepBtn.layer.masksToBounds = true
        
        sendCodeBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        sendCodeBtn.layer.cornerRadius = 5
        sendCodeBtn.layer.masksToBounds = true
        
        forgetPasswordScrollView.delaysContentTouches = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func checkIfCodeEnabled() {
        sendCodeBtn.enabled = !phone.isEmpty && phone.characters.count == 11
    }
    
    func checkIfNextStepEnabled() {
        nextStepBtn.enabled = !phone.isEmpty && !code.isEmpty
    }
    
    func checkVerificationCode() {
        SMSSDK.commitVerificationCode(self.code, phoneNumber: phone, zone: "86") { (error) in
            if ((error == nil)) {
                let storyboard = UIStoryboard(name:"Main", bundle: nil)
                let viewController = storyboard.instantiateViewControllerWithIdentifier("UpdatePassword") as! UpdatePasswordController
                viewController.phone = self.phone
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
