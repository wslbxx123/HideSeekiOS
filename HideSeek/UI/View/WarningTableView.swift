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
        self.screenHeight = UIScreen.main.bounds.height - 44
        self.separatorStyle = UITableViewCellSeparatorStyle.none
        BaseInfoUtil.cancelButtonDelay(self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: "warningCell") as! WarningTableViewCell
        
        if warningList.count < (indexPath as NSIndexPath).row + 1 {
            return cell
        }
        let warning = warningList.object(at: (indexPath as NSIndexPath).row) as! Warning
        
        cell.initWarning(warning)
        cell.updateGoalDelegate = updateGoalDelegate
        BaseInfoUtil.cancelButtonDelay(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return warningList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
