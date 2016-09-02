//
//  FeedbackController.swift
//  HideSeek
//
//  Created by apple on 8/30/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class FeedbackController: UIViewController, UIScrollViewDelegate {
    let HtmlType = "text/html"
    @IBOutlet weak var feedbackScrollView: UIScrollView!
    @IBOutlet weak var commitBtn: UIButton!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var suggestBtn: UIButton!
    @IBOutlet weak var complainBtn: UIButton!
    @IBOutlet weak var queryBtn: UIButton!
    @IBOutlet weak var contactTextField: UITextField!
    var type: Int = 0
    var manager: AFHTTPRequestOperationManager!
    var contact: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        initView()
    }
    
    override func viewDidLayoutSubviews() {
        feedbackScrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 700)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func suggestBtnClicked(sender: AnyObject) {
        type = 0
        suggestBtn.setBackgroundImage(
            suggestBtn.getImageWithColor(BaseInfoUtil.stringToRGB("#fccb05")), forState: UIControlState.Normal)
        queryBtn.setBackgroundImage(
            queryBtn.getImageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        complainBtn.setBackgroundImage(
            queryBtn.getImageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
    }
    
    @IBAction func queryBtnClicked(sender: AnyObject) {
        type = 1
        suggestBtn.setBackgroundImage(
            queryBtn.getImageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        queryBtn.setBackgroundImage(
            suggestBtn.getImageWithColor(BaseInfoUtil.stringToRGB("#fccb05")), forState: UIControlState.Normal)
        complainBtn.setBackgroundImage(
            queryBtn.getImageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
    }
    
    
    @IBAction func complainBtnClicked(sender: AnyObject) {
        type = 2
        suggestBtn.setBackgroundImage(
            queryBtn.getImageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        queryBtn.setBackgroundImage(
            queryBtn.getImageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        complainBtn.setBackgroundImage(
            suggestBtn.getImageWithColor(BaseInfoUtil.stringToRGB("#fccb05")), forState: UIControlState.Normal)
    }
    
    @IBAction func commitBtnClicked(sender: AnyObject) {
        if feedbackTextView.text.isEmpty {
            HudToastFactory.show(NSLocalizedString("ERROR_FEEDBACK_EMPTY", comment: "The content of feedback cannot be empty"), view: self.view, type: HudToastFactory.MessageType.ERROR)
            return
        }
        
        let paramDict = NSMutableDictionary()
        paramDict["type"] = "\(type)"
        paramDict["content"] = feedbackTextView.text
        paramDict["contact"] = contactTextField.text
        
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        
        manager.POST(UrlParam.ADD_FEEDBACK_URL,
                     parameters: paramDict,
                     success: { (operation, responseObject) in
                        let response = responseObject as! NSDictionary
                        print("JSON: " + responseObject.description!)
                        self.setInfoFromCallback(response)
                        self.feedbackTextView.text = ""
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
    
    @IBAction func contactChanged(sender: AnyObject) {
        contact = contactTextField.text
        
        if contact == nil || contact.isEmpty {
            commitBtn.enabled = false
        } else {
            commitBtn.enabled = true
        }
    }
    
    func setInfoFromCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            let alertController = UIAlertController(title: nil,
                                                    message: NSLocalizedString("SUCCESS_COMMIT_FEEDBACK", comment: "Commit feedback successfully"), preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                                         style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }
    
    func initView() {
        self.automaticallyAdjustsScrollViewInsets = false
        commitBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        commitBtn.layer.cornerRadius = 5
        commitBtn.layer.masksToBounds = true
        feedbackScrollView.delaysContentTouches = false
        feedbackScrollView.delegate = self
        suggestBtn.setBackgroundColor("#ffffff", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        suggestBtn.layer.cornerRadius = 5
        suggestBtn.layer.masksToBounds = true
        suggestBtn.adjustsImageWhenHighlighted = false
        complainBtn.setBackgroundColor("#ffffff", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        complainBtn.layer.cornerRadius = 5
        complainBtn.layer.masksToBounds = true
        complainBtn.adjustsImageWhenHighlighted = false
        queryBtn.setBackgroundColor("#ffffff", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        queryBtn.layer.cornerRadius = 5
        queryBtn.layer.masksToBounds = true
        queryBtn.adjustsImageWhenHighlighted = false
        suggestBtn.setBackgroundImage(
            suggestBtn.getImageWithColor(BaseInfoUtil.stringToRGB("#fccb05")), forState: UIControlState.Normal)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        feedbackTextView.resignFirstResponder()
        contactTextField.resignFirstResponder()
    }
}
