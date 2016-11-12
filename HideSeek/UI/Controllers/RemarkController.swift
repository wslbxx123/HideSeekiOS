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
    var friend: User!
    var rightBarButton: UIBarButtonItem!
    var manager: CustomRequestManager!

    @IBAction func aliasChanged(_ sender: AnyObject) {
        if(aliasValue != aliasTextField.text) {
            aliasValue = aliasTextField.text
            
            rightBarButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        aliasTextField.text = aliasValue
        rightBarButton = UIBarButtonItem(title: NSLocalizedString("SAVE", comment: "Save"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(RemarkController.saveBtnClicked))
        rightBarButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = rightBarButton
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func saveBtnClicked() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let paramDict = NSMutableDictionary()
        paramDict["remark"] = aliasValue
        paramDict["friend_id"] = "\(friend.pkId)"
        _ = manager.POST(UrlParam.UPDATE_REMARK, paramDict: paramDict, success: { (operation, responseObject) in
            let response = responseObject as! NSDictionary
            print("JSON: " + responseObject.debugDescription)
            self.setInfoFromCallback(response)
            hud.removeFromSuperview()
            _ = self.navigationController?.popViewController(animated: true)
        }) { (operation, error) in
            print("Error: " + error.localizedDescription)
            let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
            hud.removeFromSuperview()
        }
    }
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        if code == CodeParam.SUCCESS {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
        }
    }
}
