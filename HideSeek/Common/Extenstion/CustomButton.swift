//
//  CustomButton.swift
//  HideSeek
//
//  Created by apple on 6/25/16.
//  Copyright © 2016 mj. All rights reserved.
//

extension UIButton {
    func setBackgroundColor(_ defaultColorStr: String, selectedColorStr: String, disabledColorStr: String) {
        self.setImage(getImageWithColor(BaseInfoUtil.stringToRGB(defaultColorStr)),
                                for: UIControlState())
        self.setImage(getImageWithColor(BaseInfoUtil.stringToRGB(selectedColorStr)),
                                for: UIControlState.selected)
        self.setImage(getImageWithColor(BaseInfoUtil.stringToRGB(disabledColorStr)),
                                for: UIControlState.disabled)
        
        self.setBackgroundImage(getImageWithColor(BaseInfoUtil.stringToRGB(defaultColorStr)),
                                for: UIControlState())
        self.setBackgroundImage(getImageWithColor(BaseInfoUtil.stringToRGB(selectedColorStr)),
                                for: UIControlState.selected)
        self.setBackgroundImage(getImageWithColor(BaseInfoUtil.stringToRGB(disabledColorStr)),
                                for: UIControlState.disabled)
    }
    
    func getImageWithColor(_ color: UIColor) ->UIImage{
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0);
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        context?.setFillColor(color.cgColor);
        context?.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image!;
    }
    
    func setImageUpTitleDown() {
        let internalImage = self.image(for: UIControlState())
        self.titleEdgeInsets = UIEdgeInsetsMake(30, -internalImage!.size.width, 0, 0)
        
        let height = self.titleLabel?.frame.size.height
        let width = BaseInfoUtil.getLabelWidth((self.titleLabel?.font.pointSize)!, height: height!, message: self.currentTitle!)
        self.imageEdgeInsets = UIEdgeInsetsMake(-8, 0, 0, -width)
    }
}
