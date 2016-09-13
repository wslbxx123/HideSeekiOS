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
    let TAG_DATE_LABEL = 4
    let TAG_DATE_VIEW = 5
    let VISIBLE_REFRESH_COUNT = 2;
    
    var recordList: NSMutableArray!
    var tabelViewCell: UITableViewCell!
    var messageWidth: CGFloat!
    var infiniteScrollingView: UIView!
    var loadMoreDelegate: LoadMoreDelegate!
    var screenHeight: CGFloat!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.recordList = NSMutableArray()
        self.setupInfiniteScrollingView()
        self.screenHeight = UIScreen.mainScreen().bounds.height - 184
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCellWithIdentifier("recordCell")! as UITableViewCell
        
        if recordList.count < indexPath.row + 1 {
            return cell
        }
        
        let record = recordList.objectAtIndex(indexPath.row) as! Record
        
        let dateLabel = cell.viewWithTag(TAG_DATE_LABEL) as! UILabel
        let timeLabel = cell.viewWithTag(TAG_TIME_LABEL) as! UILabel
        let goalImageView = cell.viewWithTag(TAG_GOAL_IMAGEVIEW) as! UIImageView
        let scoreLabel = cell.viewWithTag(TAG_SCORE_LABEL) as! UILabel

        timeLabel.text = record.time
        
        goalImageView.image = UIImage(named: GoalImageFactory.get(record.goalType, showTypeName: record.showTypeName))
        
        if record.score >= 0 {
            scoreLabel.text = "+" + String(record.score)
        } else {
            scoreLabel.text = String(record.score)
        }
        
        dateLabel.text = String(record.date)
        
        if indexPath.row == 0 ||
            record.date != (recordList.objectAtIndex(indexPath.row - 1) as! Record).date {
        } else {
            dateLabel.text = ""
        }

        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordList.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if recordList.count < indexPath.row + 1 {
            return 0
        }
        
        let record = recordList.objectAtIndex(indexPath.row) as! Record
        
        if indexPath.row == 0 ||
            record.date != (recordList.objectAtIndex(indexPath.row - 1) as! Record).date {
            return 100
        }
        
        return 58
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let indexPath = self.indexPathForRowAtPoint(CGPointMake(scrollView.contentOffset.x + 30, scrollView.contentOffset.y + screenHeight - 100))
        
        if indexPath != nil {
            print(indexPath!.row)
        }
        
        if indexPath != nil && indexPath!.row >= self.recordList.count - VISIBLE_REFRESH_COUNT && self.recordList.count >= 10{
            self.tableFooterView = self.infiniteScrollingView
            self.tableFooterView?.hidden = false
            
            loadMoreDelegate?.loadMore()
        }
    }
    
    func getMessage(goalType: Goal.GoalTypeEnum)-> String {
        switch(goalType) {
        case .mushroom:
            return NSLocalizedString("MESSAGE_GET_MUSHROOM", comment: "Get a mushroom into a sack successfully")
        case .monster:
            return NSLocalizedString("MESSAGE_GET_MONSTER", comment: "Beat a monster successfully")
        case .bomb:
            return NSLocalizedString("MESSAGE_GET_BOMB", comment: "A bomb went off, ouch")
        default:
            return ""
        }
    }
    
    func setupInfiniteScrollingView() {
        let screenWidth = UIScreen.mainScreen().bounds.width
        self.infiniteScrollingView = UIView(frame: CGRectMake(0, self.contentSize.height, screenWidth, 25))
        self.infiniteScrollingView!.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.infiniteScrollingView!.backgroundColor = UIColor.whiteColor()
        
        let loadinglabel = UILabel()
        loadinglabel.frame.size = CGSize(width: 100, height: 20)
        loadinglabel.text = NSLocalizedString("LOADING", comment: "Loading...")
        loadinglabel.textAlignment = NSTextAlignment.Center
        loadinglabel.font = UIFont.systemFontOfSize(15.0)
        loadinglabel.center = CGPoint(x: self.infiniteScrollingView.bounds.size.width / 2,
                                      y: self.infiniteScrollingView.bounds.size.height / 2)
        self.infiniteScrollingView!.addSubview(loadinglabel)
    }
}

