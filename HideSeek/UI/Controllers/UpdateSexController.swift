//
//  UpdateSexController.swift
//  HideSeek
//
//  Created by apple on 8/21/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import MBProgressHUD

class UpdateSexController: UIViewController, TouchDownDelegate, PickerViewDelegate {
    let HtmlType = "text/html"
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var sexView: MenuView!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var sexPickerView: ComboxPickerView!
    var sex: User.SexEnum = User.SexEnum.notSet
    var rightBarButton: UIBarButtonItem!
    var sexName: String?
    var manager: CustomRequestManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        sexLabel.text = sexName
        sexView.touchDownDelegate = self
        pickerView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        sexPickerView.items = [NSLocalizedString("FEMALE", comment: "Female"),
                               NSLocalizedString("MALE", comment: "Male"),
                               NSLocalizedString("SECRET", comment: "Secret")]
        sexPickerView.reloadAllComponents()
        sexPickerView.pickerViewDelegate = self
        
        let leftBarButton = UIBarButtonItem(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(UpdateSexController.cancelBtnClicked))
        self.navigationItem.leftBarButtonItem = leftBarButton
        rightBarButton = UIBarButtonItem(title: NSLocalizedString("SAVE", comment: "Save"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(UpdateSexController.saveBtnClicked))
        rightBarButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UpdateSexController.cancelEditSex))
        pickerView.isUserInteractionEnabled = true
        pickerView.addGestureRecognizer(gestureRecognizer)
    }
    
    func cancelBtnClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func saveBtnClicked() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let paramDict = NSMutableDictionary()
        paramDict["sex"] = "\(sex.rawValue)"
        _ = manager.POST(UrlParam.UPDATE_SEX, paramDict: paramDict, success: { (operation, responseObject) in
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
        
        user?.sex = User.SexEnum(rawValue: BaseInfoUtil.getIntegerFromAnyObject(profileInfo["sex"]))!
    }

    func touchDown(_ tag: Int) {
        pickerView.isHidden = false
    }
    
    func cancelEditSex() {
        if sex == User.SexEnum.notSet {
            sex = User.SexEnum.female
        }
        
        sexLabel.text = sexPickerView.items.object(at: sex.rawValue - 1) as? String
        pickerView.isHidden = true
        
        if sexLabel.text != sexName {
            self.rightBarButton.isEnabled = true
        }
    }
    
    func pickerViewSelected(_ row: Int, item: AnyObject) {
        pickerView.isHidden = true
        sex = User.SexEnum(rawValue: row + 1)!
        sexLabel.text = item as? String
        
        if sexLabel.text != sexName {
            self.rightBarButton.isEnabled = true
        }
    }
}
