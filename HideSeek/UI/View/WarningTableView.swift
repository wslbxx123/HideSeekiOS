//
//  WarningTableView.swift
//  HideSeek
//
//  Created by apple on 8/25/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class WarningTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var warningList: NSMutableArray!
    var messageWidth: CGFloat!
    var infiniteScrollingView: UIView!
    var loadMoreDelegate: LoadMoreDelegate!
    var updateGoalDelegate: UpdateGoalDelegate!
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
        let cell = self.dequeueReusableCellWithIdentifier("warningCell") as! WarningTableViewCell
        
        if warningList.count < indexPath.row + 1 {
            return cell
        }
        let warning = warningList.objectAtIndex(indexPath.row) as! Warning
        
        cell.initWarning(warning)
        cell.updateGoalDelegate = updateGoalDelegate
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
