//
//  WarningTableView.swift
//  HideSeek
//
//  Created by apple on 8/25/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class WarningTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    let TAG_GOAL_IMAGEVIEW = 1
    let TAG_MESSAGE_LABEL = 2
    let TAG_GET_BUTTON = 3
    
    var warningList: NSMutableArray!
    var messageWidth: CGFloat!
    var infiniteScrollingView: UIView!
    var loadMoreDelegate: LoadMoreDelegate!
    var screenHeight: CGFloat!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.warningList = NSMutableArray()
        self.screenHeight = UIScreen.mainScreen().bounds.height - 44
        self.separatorStyle = UITableViewCellSeparatorStyle.None
        BaseInfoUtil.cancelButtonDelay(self)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCellWithIdentifier("warningCell")! as UITableViewCell
        let warning = warningList.objectAtIndex(indexPath.row) as! Warning
        
        let goalImageView = cell.viewWithTag(TAG_GOAL_IMAGEVIEW) as! UIImageView
        let messageLabel = cell.viewWithTag(TAG_MESSAGE_LABEL) as! UILabel
        let getBtn = cell.viewWithTag(TAG_GET_BUTTON) as! UIButton
        getBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        getBtn.layer.cornerRadius = 5
        getBtn.layer.masksToBounds = true
        
        let message = NSString(format: NSLocalizedString("WATCHED_BY_MONSTER", comment: "You are watched by a %@"), warning.goal.goalName)
        messageLabel.text = message as String
        
        goalImageView.image = UIImage(named: GoalImageFactory.get(warning.goal.type, showTypeName: warning.goal.showTypeName))
        
        BaseInfoUtil.cancelButtonDelay(cell)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return warningList.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
}
