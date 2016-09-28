//
//  AboutController.swift
//  HideSeek
//
//  Created by apple on 8/31/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class AboutController: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! NSString
        let buildVersion = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! NSString
        
        let format = NSLocalizedString("VERSION_FORMAT", comment: "HideSeek %@.%@")
        versionLabel.text = NSString(format: format, version, buildVersion) as String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
