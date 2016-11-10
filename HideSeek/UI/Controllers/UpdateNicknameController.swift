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
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as! Set<String>
    }

    @IBAction func nicknameChanged(_ sender: AnyObject) {
        if(value != nicknameTextField.text) {
            value = nicknameTextField.text
            
            rightBarButton.isEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        nicknameTextField.text = value
        let leftBarButton = UIBarButtonItem(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(UpdateNicknameController.cancelBtnClicked))
        self.navigationItem.leftBarButtonItem = leftBarButton
        rightBarButton = UIBarButtonItem(title: NSLocalizedString("SAVE", comment: "Save"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(UpdateNicknameController.saveBtnClicked))
        rightBarButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func cancelBtnClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveBtnClicked() {
        var hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        let paramDict = NSMutableDictionary()
        paramDict["nickname"] = value
        manager.POST(UrlParam.UPDATE_NICKNAME, paramDict: paramDict, success: { (operation, responseObject) in
            let response = responseObject as! NSDictionary
            print("JSON: " + responseObject.description!)
            self.setInfoFromCallback(response)
            hud.removeFromSuperview()
            self.navigationController?.popViewController(animated: true)
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
            let result = response["result"] as! NSDictionary
            updateUser(result)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }

    func updateUser(_ profileInfo: NSDictionary) {
        let user = UserCache.instance.user
        
        user?.nickname = profileInfo["nickname"] as! NSString
    }
}
