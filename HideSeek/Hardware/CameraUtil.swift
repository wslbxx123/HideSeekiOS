//
//  CameraUtil.swift
//  HideSeek
//
//  Created by apple on 6/13/16.
//  Copyright © 2016 mj. All rights reserved.
//

import Foundation
import UIKit

class CameraUtil {
    class func isAvailable()->Bool {
        return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
}