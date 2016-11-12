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
    
    var photoUrl: String!
    var smallPhotoUrl: String!
    var ifEdit: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.setWebImage(photoUrl, smallPhotoUrl: smallPhotoUrl, defaultImage: "default_photo", isCache: true)
        
        if ifEdit {
            let rightBarButton = UIBarButtonItem(image: UIImage(named: "more"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(PhotoController.moreBtnClicked))
            self.navigationItem.rightBarButtonItem = rightBarButton
        }
        
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func moreBtnClicked() {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = self.navigationItem.rightBarButtonItem
        }
        
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
    
    func updatePhoto() {
        let paramDict = NSMutableDictionary()
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        _ = manager.POST(UrlParam.UPDATE_PHOTO_URL, paramDict: paramDict, constructingBodyWithBlock: { (formData) in
            if self.croppedImage != nil {
                let imgData = UIImageJPEGRepresentation(self.croppedImage!, 1);
                formData.appendPart(withFileData: imgData!, name: "photo", fileName: "photo", mimeType: "image/jpeg")
            }
            }, success: { (operation, responseObject) in
                let response = responseObject as! NSDictionary
                self.setInfoFromCallback(response)
                print("JSON: " + responseObject.description!)
                hud.removeFromSuperview()
            }) { (operation, error) in
                print("Error: " + error.localizedDescription)
                let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
                hud.removeFromSuperview()
        }
    }
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"] as AnyObject)
        
        if code == CodeParam.SUCCESS {
            let result = response["result"] as! NSDictionary
            let user = UserCache.instance.user
            user?.photoUrl = result["photo_url"] as! NSString
            user?.smallPhotoUrl = result["small_photo_url"] as! NSString
            self.photoImageView.image = croppedImage
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }

    func cropViewControllerDidCancel(_ controller: PECropViewController!) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ controller: PECropViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        controller.dismiss(animated: true, completion: nil)
        self.croppedImage = croppedImage
        updatePhoto()
    }
    
    func scaleImage(_ image: UIImage, toScale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: image.size.width * toScale, height: image.size.height * toScale))
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width * toScale, height: image.size.height * toScale))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}
