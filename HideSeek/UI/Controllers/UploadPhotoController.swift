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
    
    var manager: AFHTTPRequestOperationManager!
    var phone: String!
    var nickname: String!
    var password: String!
    var region: String!
    var sex: User.SexEnum = User.SexEnum.notSet
    var croppedImage: UIImage!
    
    @IBAction func closeBtnClicked(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func cameraBtnClicked(sender: AnyObject) {
        photoImageViewClicked()
    }
    
    @IBAction func matchRoleBtnClicked(sender: AnyObject) {
        let channalId = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.CHANNEL_ID) as! String
        let paramDict = NSMutableDictionary()
        let role = arc4random_uniform(5)
        paramDict["phone"] = phone
        paramDict["nickname"] = nickname
        paramDict["password"] = password
        paramDict["role"] = "\(role)"
        paramDict["sex"] = "\(sex.rawValue)"
        paramDict["channel_id"] = channalId
        
        if region != nil {
            paramDict["region"] = region
        }
        
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        manager.POST(UrlParam.REGISTER_URL, parameters: paramDict, constructingBodyWithBlock: { (formData) in

            if self.croppedImage != nil {
                let imgData = UIImageJPEGRepresentation(self.croppedImage!, 1);
                formData.appendPartWithFileData(imgData!, name: "photo", fileName: "photo", mimeType: "image/jpeg")
            }}, success: { (operation, responseObject) in
                let response = responseObject as! NSDictionary
                self.setInfoFromCallback(response)
                print("JSON: " + responseObject.description!)
                hud.removeFromSuperview()
                hud = nil
            }) { (operation, error) in
                print("Error: " + error.localizedDescription)
                let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
                hud.removeFromSuperview()
                hud = nil
        }
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
    
    func setInfoFromCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            UserCache.instance.setUser(response["result"] as! NSDictionary)
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier("matchRole") as! MatchRoleController
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.layer.masksToBounds = true
        photoImageView.userInteractionEnabled = true
        photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UploadPhotoController.photoImageViewClicked)))
        matchRoleBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        sexPickerView.items = [NSLocalizedString("FEMALE", comment: "Female"),
                               NSLocalizedString("MALE", comment: "Male"),
                               NSLocalizedString("SECRET", comment: "Secret")]
        sexPickerView.reloadAllComponents()
        
        sexView.addTarget(self, action: #selector(UploadPhotoController.sexViewClicked), forControlEvents: UIControlEvents.TouchDown)
        regionView.addTarget(self, action: #selector(UploadPhotoController.regionViewClicked), forControlEvents: UIControlEvents.TouchDown)
        pickerView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        sexPickerView.pickerViewDelegate = self
        manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sexViewClicked() {
        pickerView.hidden = false
    }
    
    func regionViewClicked() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("region") as! RegionController
        self.navigationController?.pushViewController(viewController, animated: true)
        viewController.callBack { (name) in
            self.region = name
            self.regionResultLabel.text = name
        }
    }
    
    func pickerViewSelected(row: Int, item: AnyObject) {
        pickerView.hidden = true
        sex = User.SexEnum(rawValue: row + 1)!
        sexResultLabel.text = item as? String
    }
    
    func photoImageViewClicked() {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("CAMERA", comment: "Camera"), style: UIAlertActionStyle.Default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                picker.sourceType = UIImagePickerControllerSourceType.Camera
            } else {
                NSLog("模拟器无法打开相机")
            }
            self.presentViewController(picker, animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)
        
        let photoLibraryAction = UIAlertAction(title: NSLocalizedString("PHOTO_LIBRARY", comment: "Photo Library"), style: UIAlertActionStyle.Default) { (action) in
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: UIAlertActionStyle.Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        UIApplication.sharedApplication().statusBarHidden = false
        
        let mediaType = info[UIImagePickerControllerMediaType]
        var data: NSData
        if mediaType != nil && mediaType!.isEqualToString("public.image") {
            let originImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            let scaledImage = scaleImage(originImage, toScale: 0.8)
            
            if (UIImagePNGRepresentation(scaledImage) == nil){
                data = UIImageJPEGRepresentation(scaledImage, 1)!
            } else {
                data = UIImagePNGRepresentation(scaledImage)!
            }
            
            let image = UIImage(data: data)
            
            picker.dismissViewControllerAnimated(true, completion: {
                let controller = PECropViewController()
                controller.delegate = self
                controller.image = image
                
                let width = image!.size.width;
                let height = image!.size.height;
                let length = min(width, height);
                controller.imageCropRect = CGRectMake((width - length) / 2,
                    (height - length) / 2,
                    length,
                    length);
                controller.keepingCropAspectRatio = true
                
                let navigationController = UINavigationController.init(rootViewController: controller)
                
                self.presentViewController(navigationController, animated: true, completion: nil)
            })
        }
    }
    
    func scaleImage(image: UIImage, toScale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width * toScale, image.size.height * toScale))
        image.drawInRect(CGRectMake(0, 0, image.size.width * toScale, image.size.height * toScale))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    func cropViewControllerDidCancel(controller: PECropViewController!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cropViewController(controller: PECropViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        self.croppedImage = croppedImage
        self.photoImageView.image = croppedImage
    }
}
