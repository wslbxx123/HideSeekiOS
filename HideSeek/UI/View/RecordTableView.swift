//
//  RecordTableView.swift
//  HideSeek
//
//  Created by apple on 7/8/16.
//  Copyright © 2016 mj. All rights reserved.
//

class RecordTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    let TAG_TIME_LABEL = 1
    let TAG_GOAL_IMAGEVIEW = 2
    let TAG_SCORE_LABEL = 3
    
    var recordList: NSArray!
    var tabelViewCell: UITableViewCell!
    var messageWidth: CGFloat!
    var infiniteScrollingView: UIView!
    var loadMoreDelegate: LoadMoreDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.recordList = NSArray()
        self.setupInfiniteScrollingView()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return recordList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCellWithIdentifier("recordCell")! as UITableViewCell
        let record = recordList.objectAtIndex(indexPath.section) as! Record
        let recordItem = record.recordItems.objectAtIndex(indexPath.row) as! RecordItem
        
        let timeLabel = cell.viewWithTag(TAG_TIME_LABEL) as! UILabel
        let goalImageView = cell.viewWithTag(TAG_GOAL_IMAGEVIEW) as! UIImageView
        let scoreLabel = cell.viewWithTag(TAG_SCORE_LABEL) as! UILabel

        timeLabel.text = recordItem.time
        switch(recordItem.goalType) {
        case .mushroom:
            goalImageView.image = UIImage(named: "mushroom")
            break
        case .monster:
            goalImageView.image = UIImage(named: "monster")
            break
        case .bomb:
            goalImageView.image = UIImage(named: "bomb")
            break
        }
        scoreLabel.text = String(recordItem.scoreSum)

        if indexPath.section == recordList.count - 1 &&
            indexPath.row == record.recordItems.count - 1 &&
            getRecordCount() >= 10 {
            self.tableFooterView = self.infiniteScrollingView
            
            loadMoreDelegate?.loadMore()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let record = recordList.objectAtIndex(section) as! Record
        
        return record.recordItems.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let record = recordList.objectAtIndex(section) as! Record
        
        return record.date
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func getRecordCount() -> Int {
        var count: Int = 0
        
        for record in recordList {
            let recordInfo = record as! Record
            
            count += recordInfo.recordItems.count
        }
        
        return count
    }
    
    func getMessage(goalType: Goal.GoalTypeEnum)-> String {
        switch(goalType) {
        case .mushroom:
            return NSLocalizedString("MESSAGE_GET_MUSHROOM", comment: "Get a mushroom into a sack successfully")
        case .monster:
            return NSLocalizedString("MESSAGE_GET_MONSTER", comment: "Beat a monster successfully")
        case .bomb:
            return NSLocalizedString("MESSAGE_GET_BOMB", comment: "A bomb went off, ouch")
        }
    }
    
    func setupInfiniteScrollingView() {
        let screenWidth = UIScreen.mainScreen().bounds.width
        self.infiniteScrollingView = UIView(frame: CGRectMake(0, self.contentSize.height, screenWidth, 60))
        self.infiniteScrollingView!.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.infiniteScrollingView!.backgroundColor = UIColor.whiteColor()
        
        let loadinglabel = UILabel()
        loadinglabel.frame.size = CGSize(width: 100, height: 50)
        loadinglabel.text = NSLocalizedString("LOADING", comment: "Loading...")
        loadinglabel.textAlignment = NSTextAlignment.Center
        loadinglabel.font = UIFont.systemFontOfSize(15.0)
        loadinglabel.center = CGPoint(x: self.infiniteScrollingView.bounds.size.width / 2,
                                      y: self.infiniteScrollingView.bounds.size.height / 2)
        self.infiniteScrollingView!.addSubview(loadinglabel)
    }
}

