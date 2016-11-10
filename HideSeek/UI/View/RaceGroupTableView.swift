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
        self.screenHeight = UIScreen.main.bounds.height - 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: "raceGroupCell") as! RaceGroupTableViewCell
        
        if raceGroupList.count < (indexPath as NSIndexPath).row + 1 {
            return cell
        }
        
        let raceGroup = raceGroupList.object(at: (indexPath as NSIndexPath).row) as! RaceGroup
        cell.goToPhotoDelegate = goToPhotoDelegate
        cell.initRaceGroup(raceGroup)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        BaseInfoUtil.cancelButtonDelay(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return raceGroupList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if raceGroupList.count < (indexPath as NSIndexPath).row + 1 {
            return 0
        }
        
        let raceGroup = raceGroupList.object(at: (indexPath as NSIndexPath).row) as! RaceGroup
        let message = RaceGroupMessageFactory.get(raceGroup.recordItem.score, goalType: raceGroup.recordItem.goalType, showTypeName: raceGroup.recordItem.showTypeName) as NSString
        
        let frame = UIScreen.main.bounds
        let labelHeight = BaseInfoUtil.getLabelHeight(15.0, width: frame.width - 130, message: message as String)
        return labelHeight + 120
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPath = self.indexPathForRow(at: CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + screenHeight))
        
        if indexPath != nil {
            print((indexPath! as NSIndexPath).row)
        }
        
        if indexPath != nil && (indexPath! as NSIndexPath).row >= self.raceGroupList.count - VISIBLE_REFRESH_COUNT && self.raceGroupList.count >= 10{
            self.tableFooterView = self.infiniteScrollingView
            self.tableFooterView?.isHidden = false
            
            loadMoreDelegate?.loadMore()
        }
    }
    
    func setupInfiniteScrollingView() {
        let screenWidth = UIScreen.main.bounds.width
        self.infiniteScrollingView = UIView(frame: CGRect(x: 0, y: self.contentSize.height, width: screenWidth, height: 40))
        self.infiniteScrollingView!.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.infiniteScrollingView!.backgroundColor = UIColor.white
        
        let loadinglabel = UILabel()
        loadinglabel.frame.size = CGSize(width: 100, height: 30)
        loadinglabel.text = NSLocalizedString("LOADING", comment: "Loading...")
        loadinglabel.textAlignment = NSTextAlignment.center
        loadinglabel.font = UIFont.systemFont(ofSize: 15.0)
        loadinglabel.center = CGPoint(x: self.infiniteScrollingView.bounds.size.width / 2,
                                      y: self.infiniteScrollingView.bounds.size.height / 2)
        self.infiniteScrollingView!.addSubview(loadinglabel)
    }
}
