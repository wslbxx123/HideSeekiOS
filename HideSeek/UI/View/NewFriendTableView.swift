//
//  NewFriendTableView.swift
//  HideSeek
//
//  Created by apple on 8/29/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class NewFriendTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var newFriendList: NSMutableArray!
    var screenHeight: CGFloat!
    var acceptDelegate: AcceptDelegate!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.newFriendList = NSMutableArray()
        self.screenHeight = UIScreen.mainScreen().bounds.height - 44
        self.separatorStyle = UITableViewCellSeparatorStyle.None;
        
        BaseInfoUtil.cancelButtonDelay(self)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCellWithIdentifier("newFriendCell")! as! NewFriendTableViewCell
        let friend = newFriendList.objectAtIndex(indexPath.row) as! User
        cell.initNewFriend(friend)
        cell.acceptDelegate = acceptDelegate
        
        BaseInfoUtil.cancelButtonDelay(cell)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newFriendList.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        let result = UITableViewCellEditingStyle.Delete
        
        return result
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let friend = newFriendList.objectAtIndex(indexPath.row) as! User
            NewFriendCache.instance.removeFriend(friend)
            self.reloadData()
        }
    }
}
