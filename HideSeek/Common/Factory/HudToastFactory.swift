//
//  HudToastFactory.swift
//  HideSeek
//
//  Created by apple on 6/29/16.
//  Copyright © 2016 mj. All rights reserved.
//
import MBProgressHUD

class HudToastFactory {
    class func show(message: String, view: UIView, type: MessageType) {
        var hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = message;
        hud.mode = MBProgressHUDMode.Text;
        hud.yOffset = -150
        hud.color = getMessageColor(type)
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
    
    class func getMessageColor(type: MessageType) -> UIColor {
        switch type {
        case .SUCCESS:
            return UIColor.greenColor()
        case .WARNING:
            return UIColor.yellowColor()
        case .ERROR:
            return UIColor.redColor()
        }
    }
    
    enum MessageType : Int{
        case SUCCESS = 0
        case WARNING = 1
        case ERROR = 2
    }
    
    class func showScore(score: Int, view: UIView) {
        let screenRect = UIScreen.mainScreen().bounds
        let scoreViewContents = NSBundle.mainBundle().loadNibNamed("ScoreView",
                                                                 owner: view, options: nil)
        let scoreView = scoreViewContents[0] as! ScoreView
        scoreView.layer.frame = CGRectMake(
            (screenRect.width - 100) / 2,
            (screenRect.height - 100) / 2 - 110,
            100,
            100)
        scoreView.scoreLabel.text = score > 0 ? "+\(score)" : "\(score)"
        view.addSubview(scoreView)
        scoreView.initView()
        
        UIView.animateKeyframesWithDuration(3.0, delay: 0.0, options: [], animations: {
            scoreView.alpha = 0;
            }) { (finished) in
                scoreView.removeFromSuperview()
        }
    }
}
