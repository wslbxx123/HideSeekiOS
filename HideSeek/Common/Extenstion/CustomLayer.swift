//
//  CustormLayout.swift
//  HideSeek
//
//  Created by apple on 6/22/16.
//  Copyright © 2016 mj. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
    func setBorderColorFromUIColor(color: UIColor) {
        self.borderColor = color.CGColor
    }
}