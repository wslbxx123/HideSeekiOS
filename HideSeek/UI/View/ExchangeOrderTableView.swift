//
//  ExchangeOrderTableView.swift
//  HideSeek
//
//  Created by apple on 8/11/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class ExchangeOrderTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    let VISIBLE_REFRESH_COUNT = 3;
    
    var orderList: NSMutableArray!
    var tabelViewCell: UITableViewCell!
    var messageWidth: CGFloat!
    var infiniteScrollingView: UIView!
    var loadMoreDelegate: LoadMoreDelegate!
    var screenHeight: CGFloat!
    var grayView: UIView!
    var exchangeDialogController: ExchangeDialogController!
    var screenRect: CGRect!
    var exchangeDelegate: ExchangeDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.orderList = NSMutableArray()
        self.setupInfiniteScrollingView()
        self.screenRect = UIScreen.main.bounds
        self.screenHeight = screenRect.height - 44
        
        self.delaysContentTouches = false
        BaseInfoUtil.cancelButtonDelay(self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: "orderCell")! as! ExchangeOrderTableViewCell
        if orderList.count < (indexPath as NSIndexPath).row + 1 {
            return cell
        }
        
        let exchangeOrder = orderList.object(at: (indexPath as NSIndexPath).row) as! ExchangeOrder
        cell.exchangeDelegate = exchangeDelegate
        cell.initOrder(exchangeOrder)
        
        BaseInfoUtil.cancelButtonDelay(cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPath = self.indexPathForRow(at: CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + screenHeight))
        
        if indexPath != nil {
            print((indexPath! as NSIndexPath).row)
        }
        
        if indexPath != nil && (indexPath! as NSIndexPath).row >= self.orderList.count - VISIBLE_REFRESH_COUNT && self.orderList.count >= 10{
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
