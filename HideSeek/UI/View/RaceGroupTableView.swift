//
//  MeUITableView.swift
//  HideSeek
//
//  Created by apple on 6/29/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class RaceGroupTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    let VISIBLE_REFRESH_COUNT = 3
    
    var raceGroupList: NSMutableArray!
    var tabelViewCell: UITableViewCell!
    var infiniteScrollingView: UIView!
    var loadMoreDelegate: LoadMoreDelegate!
    var goToPhotoDelegate: GoToPhotoDelegate!
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
        let cell = self.dequeueReusableCellWithIdentifier("raceGroupCell") as! RaceGroupTableViewCell
        
        if raceGroupList.count < indexPath.row + 1 {
            return cell
        }
        
        let raceGroup = raceGroupList.objectAtIndex(indexPath.row) as! RaceGroup
        cell.goToPhotoDelegate = goToPhotoDelegate
        cell.initRaceGroup(raceGroup)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        BaseInfoUtil.cancelButtonDelay(cell)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return raceGroupList.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if raceGroupList.count < indexPath.row + 1 {
            return 0
        }
        
        let raceGroup = raceGroupList.objectAtIndex(indexPath.row) as! RaceGroup
        let message = RaceGroupMessageFactory.get(raceGroup.recordItem.goalType, showTypeName: raceGroup.recordItem.showTypeName) as NSString
        
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
