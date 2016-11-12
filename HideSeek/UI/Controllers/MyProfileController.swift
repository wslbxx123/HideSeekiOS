//
//  MyProfileController.swift
//  HideSeek
//
//  Created by apple on 8/19/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class MyProfileController: UIViewController, TouchDownDelegate {
    let TAG_PHOTO_VIEW = 1
    let TAG_NICKNAME = 2
    let TAG_SEX = 3
    let TAG_REGION = 4
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var photoView: MenuView!
    @IBOutlet weak var nicknameView: MenuView!
    @IBOutlet weak var sexView: MenuView!
    @IBOutlet weak var regionView: MenuView!
    
    @IBOutlet weak var myProfileScrollView: UIScrollView!
    var photoController: PhotoController!
    var updateNicknameController: UpdateNicknameController!
    var updateSexController: UpdateSexController!
    var regionController: RegionController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        setProfileInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setProfileInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initView() {
        myProfileScrollView.delaysContentTouches = false
        photoImageView.layoutIfNeeded()
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.layer.masksToBounds = true
        self.automaticallyAdjustsScrollViewInsets = false
        photoView.tag = TAG_PHOTO_VIEW
        photoView.touchDownDelegate = self
        nicknameView.tag = TAG_NICKNAME
        nicknameView.touchDownDelegate = self
        sexView.tag = TAG_SEX
        sexView.touchDownDelegate = self
        regionView.tag = TAG_REGION
        regionView.touchDownDelegate = self
    }
    
    func setProfileInfo() {
        let user = UserCache.instance.user
        photoImageView.setWebImage(user?.smallPhotoUrl as? String, defaultImage: "default_photo", isCache: true)
        nicknameLabel.text = user?.nickname as? String
        phoneLabel.text = user?.phone as? String
        roleLabel.text = user?.roleName
        sexLabel.text = user?.sexName
        
        if user?.region == "" {
            regionLabel.text = NSLocalizedString("NOT_SET", comment: "Not Set")
        } else {
            regionLabel.text = user?.region as? String
        }
    }
    
    func touchDown(_ tag: Int) {
        switch(tag) {
        case TAG_PHOTO_VIEW:
            updatePhoto()
            break;
        case TAG_NICKNAME:
            updateNickname()
            break;
        case TAG_SEX:
            updateSex()
            break;
        case TAG_REGION:
            updateRegion()
            break;
        default:
            break;
        }
    }
    
    func updatePhoto() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        photoController = storyboard.instantiateViewController(withIdentifier: "photo") as! PhotoController
        let user = UserCache.instance.user
        photoController.photoUrl = user?.photoUrl as! String
        photoController.smallPhotoUrl = user?.smallPhotoUrl as! String
        photoController.ifEdit = true
        self.navigationController?.pushViewController(photoController, animated: true)
    }
    
    func updateNickname() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        updateNicknameController = storyboard.instantiateViewController(withIdentifier: "updateNickname") as! UpdateNicknameController
        updateNicknameController.value = UserCache.instance.user.nickname as String
        self.navigationController?.pushViewController(updateNicknameController, animated: true)
    }
    
    func updateSex() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        updateSexController = storyboard.instantiateViewController(withIdentifier: "updateSex") as! UpdateSexController
        updateSexController.sex = UserCache.instance.user.sex
        updateSexController.sexName = UserCache.instance.user.sexName
        self.navigationController?.pushViewController(updateSexController, animated: true)
    }

    func updateRegion() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        regionController = storyboard.instantiateViewController(withIdentifier: "region") as! RegionController
        
        regionController.callBack { (name) in
            self.regionLabel.text = name
            UserCache.instance.user.region = name as NSString
        }
        self.navigationController?.pushViewController(regionController, animated: true)
    }

}
