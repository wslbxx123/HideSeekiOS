//
//  ProfileController.swift
//  HideSeek
//
//  Created by apple on 8/24/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sexImageView: UIImageView!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var raceLabel: UILabel!
    @IBOutlet weak var roleImageView: UIImageView!
    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var addFriendBtn: UIButton!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    var user: User!
    
    @IBAction func goToRemark(_ sender: AnyObject) {
        if user.isFriend {
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let remarkController = storyboard.instantiateViewController(withIdentifier: "Remark") as! RemarkController
            remarkController.aliasValue = user.alias as String
            remarkController.friend = user
            self.navigationController?.pushViewController(remarkController, animated: true)
        }
    }
    
    @IBAction func addFriendBtn(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let friendVerificationController = storyboard.instantiateViewController(withIdentifier: "friendVerification") as! FriendVerificationController
        friendVerificationController.user = user
        self.present(friendVerificationController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initView() {
        self.automaticallyAdjustsScrollViewInsets = false
        
        addFriendBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        addFriendBtn.layer.cornerRadius = 5
        addFriendBtn.layer.masksToBounds = true
        if user.isFriend {
            addFriendBtn.isEnabled = false
        }
        profileScrollView.delaysContentTouches = false
        photoImageView.layoutIfNeeded()
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.layer.masksToBounds = true
        photoImageView.setWebImage(user.smallPhotoUrl as String, defaultImage: "default_photo", isCache: true)
        nameLabel.text = user.nickname as String
        
        if user.sexImageName.isEmpty {
            sexImageView.isHidden = true
        } else {
            sexImageView.image = UIImage(named: user.sexImageName)
            sexImageView.isHidden = false
        }
        regionLabel.text = user.region as String
        raceLabel.text = user.roleName
        roleImageView.image = UIImage(named: user.roleImageName)
        
        if user.isFriend {
            remarkLabel.isHidden = false
            rightArrowImageView.isHidden = false
            
            if user.alias != "" {
                nameLabel.text = user.alias as String
                nickNameLabel.isHidden = false
                nickNameLabel.text = NSString(format: NSLocalizedString("NAME", comment: "Name: %@") as NSString, user.nickname) as String
            } else {
                nickNameLabel.isHidden = true
            }
        } else {
            remarkLabel.isHidden = true
            rightArrowImageView.isHidden = true
            nickNameLabel.isHidden = true
        }
    }
}
