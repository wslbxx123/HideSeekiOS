//
//  MeControllerViewController.swift
//  HideSeek
//
//  Created by apple on 6/23/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class MeController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var notLoginLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var registerDateLabel: UILabel!
    @IBOutlet weak var profileInfoStackView: UIStackView!
    @IBOutlet weak var roleImageView: UIImageView!
    
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    @IBAction func unwindToSegue (segue : UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func goToLogin(sender: AnyObject) {
        if(UserCache.instance.ifLogin()) {
            
        } else {
            performSegueWithIdentifier("GoToLogin", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "GoToLogin") {
            let loginController = segue.destinationViewController as! LoginController;
            loginController.callBack { () -> Void in
                self.setProfileInfo()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProfileInfo()

        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func setProfileInfo() {
        var photoUrl: String?
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if(UserCache.instance.ifLogin()) {
            let user = UserCache.instance.user
            photoUrl = user.photoUrl
            nameLabel.text = user.nickname
            registerDateLabel.text = dateFormatter.stringFromDate(user.registerDate)
                + " " + NSLocalizedString("JOIN", comment: "join")
            roleImageView.image = UIImage(named: user.roleImageName)
            notLoginLabel.hidden = true
            profileInfoStackView.hidden = false
        } else {
            profileInfoStackView.hidden = true
            notLoginLabel.hidden = false
        }
        
        photoImageView.setWebImage(photoUrl, defaultImage: "default_photo", isCache: true)
    }
}
