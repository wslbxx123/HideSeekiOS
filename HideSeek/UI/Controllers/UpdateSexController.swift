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
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        sexLabel.text = sexName
        sexView.touchDownDelegate = self
        pickerView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        sexPickerView.items = [NSLocalizedString("FEMALE", comment: "Female"),
                               NSLocalizedString("MALE", comment: "Male"),
                               NSLocalizedString("SECRET", comment: "Secret")]
        sexPickerView.reloadAllComponents()
        sexPickerView.pickerViewDelegate = self
        
        let leftBarButton = UIBarButtonItem(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UpdateSexController.cancelBtnClicked))
        self.navigationItem.leftBarButtonItem = leftBarButton
        rightBarButton = UIBarButtonItem(title: NSLocalizedString("SAVE", comment: "Save"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UpdateSexController.saveBtnClicked))
        rightBarButton.enabled = false
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UpdateSexController.cancelEditSex))
        pickerView.userInteractionEnabled = true
        pickerView.addGestureRecognizer(gestureRecognizer)
    }
    
    func cancelBtnClicked() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func saveBtnClicked() {
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        let paramDict = NSMutableDictionary()
        paramDict["sex"] = "\(sex.rawValue)"
        manager.POST(UrlParam.UPDATE_SEX, paramDict: paramDict, success: { (operation, responseObject) in
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
        
        user.sex = User.SexEnum(rawValue: (profileInfo["sex"] as! NSString).integerValue)!
    }

    func touchDown(tag: Int) {
        pickerView.hidden = false
    }
    
    func cancelEditSex() {
        if sex == User.SexEnum.notSet {
            sex = User.SexEnum.female
        }
        
        sexLabel.text = sexPickerView.items.objectAtIndex(sex.rawValue - 1) as? String
        pickerView.hidden = true
        
        if sexLabel.text != sexName {
            self.rightBarButton.enabled = true
        }
    }
    
    func pickerViewSelected(row: Int, item: AnyObject) {
        pickerView.hidden = true
        sex = User.SexEnum(rawValue: row + 1)!
        sexLabel.text = item as? String
        
        if sexLabel.text != sexName {
            self.rightBarButton.enabled = true
        }
    }
}
