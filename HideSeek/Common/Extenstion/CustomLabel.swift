//
//  CustomNSString.swift
//  HideSeek
//
//  Created by apple on 7/4/16.
//  Copyright © 2016 mj. All rights reserved.
//

extension UILabel {
    func modifyHeight() {
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let attributes = NSDictionary(object: self.font, forKey: NSFontAttributeName as NSCopying)
        let size = CGSize(width: self.frame.width, height: CGFloat(MAXFLOAT))
        let stringRect = self.text!.boundingRect(with: size,
                                                         options: option,
                                                         attributes: attributes as? [String : AnyObject],
                                                         context: nil)
        self.layer.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: stringRect.size.width, height: stringRect.size.height)
        
    }
    
    func modifyWidth() {
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let attributes = NSDictionary(object: self.font, forKey: NSFontAttributeName as NSCopying)
        let size = CGSize(width: CGFloat(MAXFLOAT), height: self.frame.height)
        let stringRect = self.text!.boundingRect(with: size,
                                                         options: option,
                                                         attributes: attributes as? [String : AnyObject],
                                                         context: nil)
        self.layer.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: stringRect.size.width, height: stringRect.size.height)
    }
}
