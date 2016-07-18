//
//  HudToastFactory.swift
//  HideSeek
//
//  Created by apple on 6/29/16.
//  Copyright © 2016 mj. All rights reserved.
//
import MBProgressHUD

class HudToastFactory {
    class func show(message: String, view: UIView) {
        var hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = message;
        hud.mode = MBProgressHUDMode.Text;
        hud.yOffset = -150
        hud.color = UIColor.redColor()
        hud.labelColor = UIColor.whiteColor()
        hud.cornerRadius = 25
        hud.margin = 15
        hud.showAnimated(true, whileExecutingBlock: {
            sleep(3)
        }) {
            hud.removeFromSuperview()
            hud = nil
        }

    }
}
