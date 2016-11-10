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
        self.screenHeight = UIScreen.main.bounds.height - 44
        self.separatorStyle = UITableViewCellSeparatorStyle.none;
        
        BaseInfoUtil.cancelButtonDelay(self)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: "newFriendCell")! as! NewFriendTableViewCell
        
        if newFriendList.count < (indexPath as NSIndexPath).row + 1 {
            return cell
        }
        let friend = newFriendList.object(at: (indexPath as NSIndexPath).row) as! User
        cell.initNewFriend(friend)
        cell.acceptDelegate = acceptDelegate
        
        BaseInfoUtil.cancelButtonDelay(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newFriendList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let result = UITableViewCellEditingStyle.delete
        
        return result
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            if newFriendList.count < (indexPath as NSIndexPath).row + 1 {
                return
            }
            
            let friend = newFriendList.object(at: (indexPath as NSIndexPath).row) as! User
            NewFriendCache.instance.removeFriend(friend)
            self.reloadData()
        }
    }
}
