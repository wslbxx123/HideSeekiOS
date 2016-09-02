//
//  MeUITableView.swift
//  HideSeek
//
//  Created by apple on 6/29/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class RaceGroupTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    let TAG_PHOTO_IMAGEVIEW = 1
    let TAG_NAME_LABEL = 2
    let TAG_GOAL_IMAGEVIEW = 3
    let TAG_MESSAGE_LABEL = 4
    let TAG_SCORE_LABEL = 5
    let TAG_TIME_LABEL = 6
    let VISIBLE_REFRESH_COUNT = 3;
    
    var raceGroupList: NSMutableArray!
    var tabelViewCell: UITableViewCell!
    var messageWidth: CGFloat!
    var infiniteScrollingView: UIView!
    var loadMoreDelegate: LoadMoreDelegate!
    var screenHeight: CGFloat!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.raceGroupList = NSMutableArray()
        self.setupInfiniteScrollingView()
        self.screenHeight = UIScreen.mainScreen().bounds.height - 44
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCellWithIdentifier("raceGroupCell")! as UITableViewCell
        let raceGroup = raceGroupList.objectAtIndex(indexPath.row) as! RaceGroup
        
        let photoImageView = cell.viewWithTag(TAG_PHOTO_IMAGEVIEW) as! UIImageView
        let nameLabel = cell.viewWithTag(TAG_NAME_LABEL) as! UILabel
        let goalImageView = cell.viewWithTag(TAG_GOAL_IMAGEVIEW) as! UIImageView
        let messageLabel = cell.viewWithTag(TAG_MESSAGE_LABEL) as! UILabel
        let scoreLabel = cell.viewWithTag(TAG_SCORE_LABEL) as! UILabel
        let timeLabel = cell.viewWithTag(TAG_TIME_LABEL) as! UILabel
        
        messageWidth = messageLabel.frame.width
        
        photoImageView.layer.cornerRadius = 5
        photoImageView.layer.masksToBounds = true
        photoImageView.setWebImage(raceGroup.smallPhotoUrl, defaultImage: "default_photo", isCache: true)
        nameLabel.text = raceGroup.nickname
        
        goalImageView.image = UIImage(named: GoalImageFactory.get(raceGroup.recordItem.goalType, showTypeName: raceGroup.recordItem.showTypeName))
    
        messageLabel.text = getMessage(raceGroup.recordItem.goalType, showTypeName: raceGroup.recordItem.showTypeName)
        scoreLabel.text = String.init(format: NSLocalizedString("SCORE_TITLE", comment: "Score：%d"), raceGroup.recordItem.score)
        
        timeLabel.text = raceGroup.recordItem.time
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return raceGroupList.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let raceGroup = raceGroupList.objectAtIndex(indexPath.row) as! RaceGroup
        let message = getMessage(raceGroup.recordItem.goalType, showTypeName: raceGroup.recordItem.showTypeName) as NSString
        
        let frame = UIScreen.mainScreen().bounds
        let labelHeight = BaseInfoUtil.getLabelHeight(15.0, width: frame.width - 130, message: message)
        return labelHeight + 120
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let indexPath = self.indexPathForRowAtPoint(CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + screenHeight))
        
        if indexPath != nil {
            print(indexPath!.row)
        }
        
        if indexPath != nil && indexPath!.row >= self.raceGroupList.count - VISIBLE_REFRESH_COUNT && self.raceGroupList.count >= 10{
            self.tableFooterView = self.infiniteScrollingView
            self.tableFooterView?.hidden = false
            
            loadMoreDelegate?.loadMore()
        }
    }
    
    func getMessage(goalType: Goal.GoalTypeEnum, showTypeName: String?)-> String {
        switch(goalType) {
        case .mushroom:
            return NSLocalizedString("MESSAGE_GET_MUSHROOM", comment: "Get a mushroom into a sack successfully")
        case .monster:
            return getMonsterMessage(showTypeName!)
        case .bomb:
            return NSLocalizedString("MESSAGE_GET_BOMB", comment: "A bomb went off, ouch")
        }
    }
    
    func getMonsterMessage(showTypeName: String) -> String {
        switch(showTypeName) {
            case "egg":
                return NSLocalizedString("MESSAGE_GET_EGG", comment: "So excited! Beat an egg monster successfully")
            case "cow":
                return NSLocalizedString("MESSAGE_GET_COW", comment: "You are watched by a cow monster，how smart I am to beat it in time!")
            case "bird":
                return NSLocalizedString("MESSAGE_GET_BIRD", comment: "You are watched by a cow monster，how smart I am to beat it in time!")
            case "giraffe":
                return NSLocalizedString("MESSAGE_GET_GIRAFFE", comment: "Thanks to friends,lucky to get a giraffe monster!")
            case "dragon":
                return NSLocalizedString("MESSAGE_GET_DRAGON", comment: "It is a great satisfaction to get a dragon monster, so cool!")
            default:
                return ""
        }
    }
    
    func setupInfiniteScrollingView() {
        let screenWidth = UIScreen.mainScreen().bounds.width
        self.infiniteScrollingView = UIView(frame: CGRectMake(0, self.contentSize.height, screenWidth, 40))
        self.infiniteScrollingView!.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.infiniteScrollingView!.backgroundColor = UIColor.whiteColor()
        
        let loadinglabel = UILabel()
        loadinglabel.frame.size = CGSize(width: 100, height: 30)
        loadinglabel.text = NSLocalizedString("LOADING", comment: "Loading...")
        loadinglabel.textAlignment = NSTextAlignment.Center
        loadinglabel.font = UIFont.systemFontOfSize(15.0)
        loadinglabel.center = CGPoint(x: self.infiniteScrollingView.bounds.size.width / 2,
                                      y: self.infiniteScrollingView.bounds.size.height / 2)
        self.infiniteScrollingView!.addSubview(loadinglabel)
    }
}
