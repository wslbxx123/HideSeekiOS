//
//  HudToastFactory.swift
//  HideSeek
//
//  Created by apple on 6/29/16.
//  Copyright © 2016 mj. All rights reserved.
//
import MBProgressHUD

class HudToastFactory {
    class func show(_ message: String, view: UIView, type: MessageType) {
        show(message, view: view, type: type, callback: nil)
    }
    
    class func show(_ message: String, view: UIView, type: MessageType, callback: (() -> Void)?) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = message;
        hud.mode = MBProgressHUDMode.text;
        hud.offset.y = -150
        hud.bezelView.color = getMessageColor(type)
        hud.label.textColor = UIColor.white
        hud.bezelView.layer.cornerRadius = 25
        hud.margin = 15
        
        hud.hide(animated: true, afterDelay: 3)
        hud.delegate = ProgressHudDelegate(callback: callback)
    }
    
    class func getMessageColor(_ type: MessageType) -> UIColor {
        switch type {
        case .success:
            return UIColor.green
        case .warning:
            return BaseInfoUtil.stringToRGB("#fccb05")
        case .error:
            return UIColor.red
        }
    }
    
    enum MessageType : Int{
        case success = 0
        case warning = 1
        case error = 2
    }
    
    class func showScore(_ score: Int, view: UIView) {
        let screenRect = UIScreen.main.bounds
        let scoreViewContents = Bundle.main.loadNibNamed("ScoreView",
                                                                 owner: view, options: nil)
        let scoreView = scoreViewContents?[0] as! ScoreView
        scoreView.layer.frame = CGRect(
            x: (screenRect.width - 100) / 2,
            y: (screenRect.height - 100) / 2 - 110,
            width: 100,
            height: 100)
        scoreView.scoreLabel.text = score > 0 ? "+\(score)" : "\(score)"
        view.addSubview(scoreView)
        scoreView.initView()
        
        UIView.animateKeyframes(withDuration: 3.0, delay: 0.0, options: [], animations: {
            scoreView.alpha = 0;
            }) { (finished) in
                scoreView.removeFromSuperview()
        }
    }
    
    class ProgressHudDelegate: MBProgressHUDDelegate {
        private var _callback: (() -> Void)?
        
        init(callback: (() -> Void)?) {
            self._callback = callback
        }
        
        func hudWasHidden(_ hud: MBProgressHUD) {
            _callback?()
            hud.removeFromSuperview()
        }
    }
}
