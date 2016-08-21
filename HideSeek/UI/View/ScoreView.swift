//
//  ScoreView.swift
//  HideSeek
//
//  Created by apple on 8/16/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class ScoreView: UIView {
    @IBOutlet weak var scoreLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func initView() {
        let font = UIFont(name: "STXingkai", size: 60)
        scoreLabel.font = font
    }
}
