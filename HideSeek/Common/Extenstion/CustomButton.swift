//
//  CustomButton.swift
//  HideSeek
//
//  Created by apple on 6/25/16.
//  Copyright © 2016 mj. All rights reserved.
//

extension UIButton {
    func setBackgroundColor(defaultColorStr: String, selectedColorStr: String, disabledColorStr: String) {
        self.setBackgroundImage(getImageWithColor(BaseInfoUtil.stringToRGB(defaultColorStr)),
                                forState: UIControlState.Normal)
        self.setBackgroundImage(getImageWithColor(BaseInfoUtil.stringToRGB(selectedColorStr)),
                                forState: UIControlState.Selected)
        self.setBackgroundImage(getImageWithColor(BaseInfoUtil.stringToRGB(disabledColorStr)),
                                forState: UIControlState.Disabled)
    }
    
    func getImageWithColor(color: UIColor) ->UIImage{
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    func setImageUpTitleDown() {
        let internalImage = self.imageForState(UIControlState.Normal)
        self.titleEdgeInsets = UIEdgeInsetsMake(30, -internalImage!.size.width, 0, 0)
        
        let height = self.titleLabel?.frame.size.height
        let width = BaseInfoUtil.getLabelWidth((self.titleLabel?.font.pointSize)!, height: height!, message: self.currentTitle)
        self.imageEdgeInsets = UIEdgeInsetsMake(-8, 0, 0, -width)
    }
}
