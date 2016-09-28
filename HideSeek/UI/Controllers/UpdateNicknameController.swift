//
//  UpdateProfileController.swift
//  HideSeek
//
//  Created by apple on 8/20/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import MBProgressHUD

class UpdateNicknameController: UIViewController {
    let HtmlType = "text/html"
    @IBOutlet weak var nicknameTextField: UITextField!
    var value: String?
    var rightBarButton: UIBarButtonItem!
    var manager: CustomRequestManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
    }

    @IBAction func nicknameChanged(sender: AnyObject) {
        if(value != nicknameTextField.text) {
            value = nicknameTextField.text
            
            rightBarButton.enabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        nicknameTextField.text = value
        let leftBarButton = UIBarButtonItem(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UpdateNicknameController.cancelBtnClicked))
        self.navigationItem.leftBarButtonItem = leftBarButton
        rightBarButton = UIBarButtonItem(title: NSLocalizedString("SAVE", comment: "Save"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UpdateNicknameController.saveBtnClicked))
        rightBarButton.enabled = false
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func cancelBtnClicked() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func saveBtnClicked() {
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        let paramDict = NSMutableDictionary()
        paramDict["nickname"] = value
        manager.POST(UrlParam.UPDATE_NICKNAME, paramDict: paramDict, success: { (operation, responseObject) in
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
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let result = response["result"] as! NSDictionary
            updateUser(result)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }

    func updateUser(profileInfo: NSDictionary) {
        let user = UserCache.instance.user
        
        user.nickname = profileInfo["nickname"] as! NSString
    }
}
