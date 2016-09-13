//
//  ExchangeCollectionView.swift
//  HideSeek
//
//  Created by apple on 7/25/16.
//  Copyright © 2016 mj. All rights reserved.
//

//
//  PurchaseCollectionView.swift
//  HideSeek
//
//  Created by apple on 7/20/16.
//  Copyright © 2016 mj. All rights reserved.
//

class ExchangeCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    let VISIBLE_REFRESH_COUNT = 3
    var cellIdentifier: String = "exchangeCell"
    var rewardList: NSMutableArray!
    var bound: CGRect!
    var screenHeight: CGFloat!
    var exchangeDelegate: ExchangeDelegate!
    var loadMoreDelegate: LoadMoreDelegate!
    var footer: UICollectionReusableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.dataSource = self
        self.registerClass(ExchangeCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.rewardList = NSMutableArray()
        self.bound = UIScreen.mainScreen().bounds
        self.screenHeight = bound.height
        self.delaysContentTouches = false
        BaseInfoUtil.cancelButtonDelay(self)
    }
    
    /**
     UICollectionViewDataSource
     **/
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rewardList.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! ExchangeCollectionViewCell
        
        if(indexPath.row < rewardList.count) {
            let reward = rewardList.objectAtIndex(indexPath.row) as! Reward
            cell.exchangeDelegate = exchangeDelegate
            cell.backgroundColor = UIColor.whiteColor()
            cell.reward = reward
            cell.setName(reward.name)
            cell.setImageUrl(reward.imageUrl)
            cell.setRecord(reward.record)
            cell.setExchangeCount(reward.exchangeCount)
            cell.setIntroduction(reward.introduction)
            cell.setExchangeBtn()
        }
        BaseInfoUtil.cancelButtonDelay(cell)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if rewardList.count < indexPath.row + 1 {
            return CGSizeMake(0, 0)
        }
        
        let reward = rewardList.objectAtIndex(indexPath.row) as! Reward
        
        let nameheight = BaseInfoUtil.getLabelHeight(15,
                                                     width: bound.width / 2 - 40,
                                                     message: reward.name)
        
        let height = nameheight + bound.width / 2 + 80
        return CGSizeMake((bound.width - 40) / 2, height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let edgeInsets = UIEdgeInsetsMake(15, 15, 5, 15)
        return edgeInsets
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView: UICollectionReusableView!
        
        if (kind == UICollectionElementKindSectionFooter)
        {
            footer = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView", forIndexPath: indexPath)
            footer.backgroundColor = UIColor.whiteColor()
            reusableView = footer;
        }
        return reusableView;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let indexPath = self.indexPathForItemAtPoint(CGPointMake(scrollView.contentOffset.x + 30, scrollView.contentOffset.y + screenHeight - 104))
        
        if indexPath != nil && indexPath!.row >= self.rewardList.count / 2 - VISIBLE_REFRESH_COUNT && self.rewardList.count >= 10{
            loadMoreDelegate?.loadMore()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location:CGPoint! = touches.first?.locationInView(self)
        
        print("\(location.x) : \(location.y)")
    }
}
