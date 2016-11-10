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
    func setBorderColorFromUIColor(_ color: UIColor) {
        self.borderColor = color.cgColor
    }
}
