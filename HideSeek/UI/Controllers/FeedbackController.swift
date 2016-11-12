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
    var manager: AFHTTPSessionManager!
    var contact: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        initView()
    }
    
    override func viewDidLayoutSubviews() {
        feedbackScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 700)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func suggestBtnClicked(_ sender: AnyObject) {
        type = 0
        suggestBtn.setBackgroundImage(
            suggestBtn.getImageWithColor(BaseInfoUtil.stringToRGB("#fccb05")), for: UIControlState())
        queryBtn.setBackgroundImage(
            queryBtn.getImageWithColor(UIColor.white), for: UIControlState())
        complainBtn.setBackgroundImage(
            queryBtn.getImageWithColor(UIColor.white), for: UIControlState())
    }
    
    @IBAction func queryBtnClicked(_ sender: AnyObject) {
        type = 1
        suggestBtn.setBackgroundImage(
            queryBtn.getImageWithColor(UIColor.white), for: UIControlState())
        queryBtn.setBackgroundImage(
            suggestBtn.getImageWithColor(BaseInfoUtil.stringToRGB("#fccb05")), for: UIControlState())
        complainBtn.setBackgroundImage(
            queryBtn.getImageWithColor(UIColor.white), for: UIControlState())
    }
    
    
    @IBAction func complainBtnClicked(_ sender: AnyObject) {
        type = 2
        suggestBtn.setBackgroundImage(
            queryBtn.getImageWithColor(UIColor.white), for: UIControlState())
        queryBtn.setBackgroundImage(
            queryBtn.getImageWithColor(UIColor.white), for: UIControlState())
        complainBtn.setBackgroundImage(
            suggestBtn.getImageWithColor(BaseInfoUtil.stringToRGB("#fccb05")), for: UIControlState())
    }
    
    @IBAction func commitBtnClicked(_ sender: AnyObject) {
        if feedbackTextView.text.isEmpty {
            HudToastFactory.show(NSLocalizedString("ERROR_FEEDBACK_EMPTY", comment: "The content of feedback cannot be empty"), view: self.view, type: HudToastFactory.MessageType.error)
            return
        }
        
        let paramDict = NSMutableDictionary()
        paramDict["type"] = "\(type)"
        paramDict["content"] = feedbackTextView.text
        paramDict["contact"] = contactTextField.text
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        _ = manager.post(UrlParam.ADD_FEEDBACK_URL,
                         parameters: paramDict,
                         progress: nil,
                         success: { (dataTask, responseObject) in
                            let response = responseObject as! NSDictionary
                            print("JSON: " + responseObject.debugDescription)
                            self.setInfoFromCallback(response)
                            self.feedbackTextView.text = ""
                            hud.removeFromSuperview()
            }, failure: { (dataTask, error) in
                print("Error: " + error.localizedDescription)
                let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
                hud.removeFromSuperview()
        })
    }
    
    @IBAction func contactChanged(_ sender: AnyObject) {
        contact = contactTextField.text
        
        if contact == nil || contact.isEmpty {
            commitBtn.isEnabled = false
        } else {
            commitBtn.isEnabled = true
        }
    }
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        if code == CodeParam.SUCCESS {
            let alertController = UIAlertController(title: nil,
                                                    message: NSLocalizedString("SUCCESS_COMMIT_FEEDBACK", comment: "Commit feedback successfully"), preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                                         style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
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
            suggestBtn.getImageWithColor(BaseInfoUtil.stringToRGB("#fccb05")), for: UIControlState())
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        feedbackTextView.resignFirstResponder()
        contactTextField.resignFirstResponder()
    }
}
