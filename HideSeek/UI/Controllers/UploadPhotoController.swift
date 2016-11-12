//
//  UploadPhotoController.swift
//  HideSeek
//
//  Created by apple on 7/26/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import PEPhotoCropEditor
import AFNetworking
import MBProgressHUD

class UploadPhotoController: UIViewController, UITextFieldDelegate, PickerViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,PECropViewControllerDelegate{
    let HtmlType = "text/html"
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var matchRoleBtn: UIButton!
    @IBOutlet weak var sexPickerView: ComboxPickerView!
    @IBOutlet weak var sexView: UIControl!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var sexResultLabel: UILabel!
    @IBOutlet weak var regionView: UIControl!
    @IBOutlet weak var regionResultLabel: UILabel!
    
    var manager: AFHTTPSessionManager!
    var phone: String!
    var nickname: String!
    var password: String!
    var region: String!
    var sex: User.SexEnum = User.SexEnum.notSet
    var croppedImage: UIImage!
    
    @IBAction func closeBtnClicked(_ sender: AnyObject) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func cameraBtnClicked(_ sender: AnyObject) {
        photoImageViewClicked()
    }
    
    @IBAction func matchRoleBtnClicked(_ sender: AnyObject) {
        let channalId = UserDefaults.standard.object(forKey: UserDefaultParam.CHANNEL_ID) as? String
        let paramDict = NSMutableDictionary()
        let role = arc4random_uniform(5)
        paramDict["phone"] = phone
        paramDict["nickname"] = nickname
        paramDict["password"] = password
        paramDict["role"] = "\(role)"
        paramDict["sex"] = "\(sex.rawValue)"
        paramDict["channel_id"] = channalId == nil ? "" : channalId!
        paramDict["app_platform"] = "0"
        
        if region != nil {
            paramDict["region"] = region
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        _ = manager.post(UrlParam.REGISTER_URL,
                         parameters: paramDict,
                         constructingBodyWith: { (formData) in
                            if self.croppedImage != nil {
                                let imgData = UIImageJPEGRepresentation(self.croppedImage!, 1);
                                formData.appendPart(withFileData: imgData!, name: "photo", fileName: "photo", mimeType: "image/jpeg")
                            }
            },
                         progress: nil,
                         success: { (dataTask, responseObject) in
                            let response = responseObject as! NSDictionary
                            self.setInfoFromCallback(response)
                            print("JSON: " + (responseObject as AnyObject).description!)
                            hud.removeFromSuperview()
            }, failure: { (dataTask, error) in
                print("Error: " + error.localizedDescription)
                let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
                hud.removeFromSuperview()
        })
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
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            UserCache.instance.setUser(response["result"] as! NSDictionary)
            
            PushManager.instance.register()
            GoalCache.instance.ifNeedClearMap = true
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "matchRole") as! MatchRoleController
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.layoutIfNeeded()
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.layer.masksToBounds = true
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UploadPhotoController.photoImageViewClicked)))
        matchRoleBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        sexPickerView.items = [NSLocalizedString("FEMALE", comment: "Female"),
                               NSLocalizedString("MALE", comment: "Male"),
                               NSLocalizedString("SECRET", comment: "Secret")]
        sexPickerView.reloadAllComponents()
        
        sexView.addTarget(self, action: #selector(UploadPhotoController.sexViewClicked), for: UIControlEvents.touchDown)
        regionView.addTarget(self, action: #selector(UploadPhotoController.regionViewClicked), for: UIControlEvents.touchDown)
        pickerView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        sexPickerView.pickerViewDelegate = self
        manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UploadPhotoController.cancelEditSex))
        pickerView.isUserInteractionEnabled = true
        pickerView.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelEditSex() {
        if sex == User.SexEnum.notSet {
            sex = User.SexEnum.female
        }
        
        sexResultLabel.text = sexPickerView.items.object(at: sex.rawValue - 1) as? String
        pickerView.isHidden = true
    }

    func sexViewClicked() {
        pickerView.isHidden = false
    }
    
    func regionViewClicked() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "region") as! RegionController
        self.navigationController?.pushViewController(viewController, animated: true)
        viewController.callBack { (name) in
            self.region = name
            self.regionResultLabel.text = name
        }
    }
    
    func pickerViewSelected(_ row: Int, item: AnyObject) {
        pickerView.isHidden = true
        sex = User.SexEnum(rawValue: row + 1)!
        sexResultLabel.text = item as? String
    }
    
    func photoImageViewClicked() {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("CAMERA", comment: "Camera"), style: UIAlertActionStyle.default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                picker.sourceType = UIImagePickerControllerSourceType.camera
            } else {
                NSLog("模拟器无法打开相机")
            }
            self.present(picker, animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)
        
        let photoLibraryAction = UIAlertAction(title: NSLocalizedString("PHOTO_LIBRARY", comment: "Photo Library"), style: UIAlertActionStyle.default) { (action) in
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: UIAlertActionStyle.cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        UIApplication.shared.isStatusBarHidden = false
        
        let mediaType = info[UIImagePickerControllerMediaType]
        var data: Data
        if mediaType != nil && (mediaType! as AnyObject).isEqual(to: "public.image") {
            let originImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            let scaledImage = scaleImage(originImage, toScale: 0.8)
            
            if (UIImagePNGRepresentation(scaledImage) == nil){
                data = UIImageJPEGRepresentation(scaledImage, 1)!
            } else {
                data = UIImagePNGRepresentation(scaledImage)!
            }
            
            let image = UIImage(data: data)
            
            picker.dismiss(animated: true, completion: {
                let controller = PECropViewController()
                controller.delegate = self
                controller.image = image
                
                let width = image!.size.width;
                let height = image!.size.height;
                let length = min(width, height);
                controller.imageCropRect = CGRect(x: (width - length) / 2,
                    y: (height - length) / 2,
                    width: length,
                    height: length);
                controller.keepingCropAspectRatio = true
                
                let navigationController = UINavigationController.init(rootViewController: controller)
                
                self.present(navigationController, animated: true, completion: nil)
            })
        }
    }
    
    func scaleImage(_ image: UIImage, toScale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: image.size.width * toScale, height: image.size.height * toScale))
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width * toScale, height: image.size.height * toScale))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    func cropViewControllerDidCancel(_ controller: PECropViewController!) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ controller: PECropViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        controller.dismiss(animated: true, completion: nil)
        self.croppedImage = croppedImage
        self.photoImageView.image = croppedImage
    }
}
