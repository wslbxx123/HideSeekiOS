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
    let TAG_GOAL_NAME_LABEL = 6
    let TAG_WHITE_VIEW = 7
    let VISIBLE_REFRESH_COUNT = 2;
    
    var recordList: NSMutableArray!
    var tabelViewCell: UITableViewCell!
    var messageWidth: CGFloat!
    var infiniteScrollingView: UIView!
    var loadMoreDelegate: LoadMoreDelegate!
    var screenHeight: CGFloat!
    let dateFormatter = DateFormatter()
    var customDateFormatter = DateFormatter()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.recordList = NSMutableArray()
        self.setupInfiniteScrollingView()
        self.screenHeight = UIScreen.main.bounds.height - 184
        dateFormatter.dateFormat = "yyyy-MM-dd"
        customDateFormatter.dateFormat = "MM-dd"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: "recordCell")! as UITableViewCell
        
        if recordList.count < (indexPath as NSIndexPath).row + 1 {
            return cell
        }
        
        let record = recordList.object(at: (indexPath as NSIndexPath).row) as! Record
        
        let dateLabel = cell.viewWithTag(TAG_DATE_LABEL) as! UILabel
        let timeLabel = cell.viewWithTag(TAG_TIME_LABEL) as! UILabel
        let goalImageView = cell.viewWithTag(TAG_GOAL_IMAGEVIEW) as! UIImageView
        let scoreLabel = cell.viewWithTag(TAG_SCORE_LABEL) as! UILabel
        let goalNameLabel = cell.viewWithTag(TAG_GOAL_NAME_LABEL) as! UILabel
        let whiteView = cell.viewWithTag(TAG_WHITE_VIEW)

        timeLabel.text = record.time
        
        goalImageView.image = UIImage(named: GoalImageFactory.get(record.goalType, showTypeName: record.showTypeName))
        goalNameLabel.text = record.goalName
        
        if record.score >= 0 {
            scoreLabel.text = "+" + String(record.score)
        } else {
            scoreLabel.text = String(record.score)
        }
        
        let date = dateFormatter.date(from: record.date)
        dateLabel.text = customDateFormatter.string(from: date!)
        
        if (indexPath as NSIndexPath).row == 0 ||
            record.date != (recordList.object(at: (indexPath as NSIndexPath).row - 1) as! Record).date {
            whiteView?.isHidden = false
        } else {
            dateLabel.text = ""
            whiteView?.isHidden = true
        }

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if recordList.count < (indexPath as NSIndexPath).row + 1 {
            return 0
        }
        
        let record = recordList.object(at: (indexPath as NSIndexPath).row) as! Record
        
        if (indexPath as NSIndexPath).row == 0 ||
            record.date != (recordList.object(at: (indexPath as NSIndexPath).row - 1) as! Record).date {
            return 110
        }
        
        return 78
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPath = self.indexPathForRow(at: CGPoint(x: scrollView.contentOffset.x + 30, y: scrollView.contentOffset.y + screenHeight - 100))
        
        if indexPath != nil {
            print((indexPath! as NSIndexPath).row)
        }
        
        if indexPath != nil && (indexPath! as NSIndexPath).row >= self.recordList.count - VISIBLE_REFRESH_COUNT && self.recordList.count >= 10{
            self.tableFooterView = self.infiniteScrollingView
            self.tableFooterView?.isHidden = false
            
            loadMoreDelegate?.loadMore()
        }
    }
    
    func getMessage(_ goalType: Goal.GoalTypeEnum)-> String {
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
        let screenWidth = UIScreen.main.bounds.width
        self.infiniteScrollingView = UIView(frame: CGRect(x: 0, y: self.contentSize.height, width: screenWidth, height: 40))
        self.infiniteScrollingView!.autoresizingMask = UIViewAutoresizing.flexibleWidth
//        self.infiniteScrollingView!.backgroundColor = UIColor.whiteColor()
        
        let loadinglabel = UILabel()
        loadinglabel.frame.size = CGSize(width: 100, height: 20)
        loadinglabel.text = NSLocalizedString("LOADING", comment: "Loading...")
        loadinglabel.textAlignment = NSTextAlignment.center
        loadinglabel.font = UIFont.systemFont(ofSize: 15.0)
        loadinglabel.center = CGPoint(x: self.infiniteScrollingView.bounds.size.width / 2,
                                      y: self.infiniteScrollingView.bounds.size.height / 2)
        self.infiniteScrollingView!.addSubview(loadinglabel)
    }
}

