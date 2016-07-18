//
//  CustomNSString.swift
//  HideSeek
//
//  Created by apple on 7/4/16.
//  Copyright © 2016 mj. All rights reserved.
//

extension UILabel {
    func modifyHeight() {
        let option = NSStringDrawingOptions.UsesLineFragmentOrigin
        let attributes = NSDictionary(object: self.font, forKey: NSFontAttributeName)
        let size = CGSizeMake(self.frame.width, CGFloat(MAXFLOAT))
        let stringRect = self.text!.boundingRectWithSize(size,
                                                         options: option,
                                                         attributes: attributes as? [String : AnyObject],
                                                         context: nil)
        self.layer.frame = CGRectMake(0, 0, stringRect.size.width, stringRect.size.height)
        
    }
}
