//
//  RateView.swift
//  HideSeek
//
//  Created by apple on 8/18/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class RateView: UIView {

    @IBOutlet weak var firstStarImageView: UIImageView!
    @IBOutlet weak var secondStarImageView: UIImageView!
    @IBOutlet weak var thirdStarImageView: UIImageView!
    @IBOutlet weak var fourthStarImageView: UIImageView!
    @IBOutlet weak var fifthStarImageView: UIImageView!
    
    func initStar(num: Int) {
        firstStarImageView.image = UIImage(named: "star")
        secondStarImageView.image = UIImage(named: "star")
        thirdStarImageView.image = UIImage(named: "star")
        fourthStarImageView.image = UIImage(named: "star")
        fifthStarImageView.image = UIImage(named: "star")
        
        if num >= 1 {
            firstStarImageView.image = UIImage(named: "selected_star")
        }
        
        if num >= 2 {
            secondStarImageView.image = UIImage(named: "selected_star")
        }
        
        if num >= 3 {
            thirdStarImageView.image = UIImage(named: "selected_star")
        }
        
        if num >= 4 {
            fourthStarImageView.image = UIImage(named: "selected_star")
        }
        
        if num >= 5 {
            fifthStarImageView.image = UIImage(named: "selected_star")
        }
    }

}
