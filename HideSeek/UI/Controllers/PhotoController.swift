//
//  PhotoController.swift
//  HideSeek
//
//  Created by apple on 8/19/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import PEPhotoCropEditor
import AFNetworking
import MBProgressHUD

class PhotoController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PECropViewControllerDelegate {
    let HtmlType = "text/html"
    @IBOutlet weak var photoImageView: UIImageView!
    var croppedImage: UIImage!
    var manager: CustomRequestManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        let user = UserCache.instance.user
        photoImageView.setWebImage(user.photoUrl as String, smallPhotoUrl: user.smallPhotoUrl as String, defaultImage: "default_photo", isCache: true)
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "more"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PhotoController.moreBtnClicked))
        self.navigationItem.rightBarButtonItem = rightBarButton
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func moreBtnClicked() {
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
    
    func updatePhoto() {
        let paramDict = NSMutableDictionary()
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        manager.POST(UrlParam.UPDATE_PHOTO_URL, paramDict: paramDict, constructingBodyWithBlock: { (formData) in
            if self.croppedImage != nil {
                let imgData = UIImageJPEGRepresentation(self.croppedImage!, 1);
                formData.appendPartWithFileData(imgData!, name: "photo", fileName: "photo", mimeType: "image/jpeg")
            }
            }, success: { (operation, responseObject) in
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
    
    func setInfoFromCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            let result = response["result"] as! NSDictionary
            let user = UserCache.instance.user
            user.photoUrl = result["photo_url"] as! NSString
            user.smallPhotoUrl = result["small_photo_url"] as! NSString
            self.photoImageView.image = croppedImage
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }

    func cropViewControllerDidCancel(controller: PECropViewController!) {
        
    }
    
    func cropViewController(controller: PECropViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        self.croppedImage = croppedImage
        updatePhoto()
    }
    
    func scaleImage(image: UIImage, toScale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width * toScale, image.size.height * toScale))
        image.drawInRect(CGRectMake(0, 0, image.size.width * toScale, image.size.height * toScale))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}
