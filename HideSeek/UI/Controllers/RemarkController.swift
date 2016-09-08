//
//  RemarkController.swift
//  HideSeek
//
//  Created by apple on 9/6/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import MBProgressHUD

class RemarkController: UIViewController {
    let HtmlType = "text/html"
    @IBOutlet weak var aliasTextField: UITextField!
    var aliasValue: String?
    var rightBarButton: UIBarButtonItem!
    var manager: CustomRequestManager!

    @IBAction func aliasChanged(sender: AnyObject) {
        if(aliasValue != aliasTextField.text) {
            aliasValue = aliasTextField.text
            
            rightBarButton.enabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        aliasTextField.text = aliasValue
        rightBarButton = UIBarButtonItem(title: NSLocalizedString("SAVE", comment: "Save"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(RemarkController.saveBtnClicked))
        rightBarButton.enabled = false
        self.navigationItem.rightBarButtonItem = rightBarButton
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func saveBtnClicked() {
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        let paramDict = NSMutableDictionary()
        paramDict["remark"] = aliasValue
        manager.POST(UrlParam.UPDATE_REMARK, paramDict: paramDict, success: { (operation, responseObject) in
            let response = responseObject as! NSDictionary
            print("JSON: " + responseObject.description!)
            self.setInfoFromCallback(response)
            hud.removeFromSuperview()
            hud = nil
            self.navigationController?.popViewControllerAnimated(true)
        }) { (operation, error) in
            print("Error: " + error.localizedDescription)
            let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
            hud.removeFromSuperview()
            hud = nil
        }
    }
    
    func setInfoFromCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }
}
