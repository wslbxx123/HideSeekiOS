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
        self.register(ExchangeCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.rewardList = NSMutableArray()
        self.bound = UIScreen.main.bounds
        self.screenHeight = bound.height
        self.delaysContentTouches = false
        BaseInfoUtil.cancelButtonDelay(self)
    }
    
    /**
     UICollectionViewDataSource
     **/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rewardList.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ExchangeCollectionViewCell
        
        if((indexPath as NSIndexPath).row < rewardList.count) {
            let reward = rewardList.object(at: (indexPath as NSIndexPath).row) as! Reward
            cell.exchangeDelegate = exchangeDelegate
            cell.backgroundColor = UIColor.white
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if rewardList.count < (indexPath as NSIndexPath).row + 1 {
            return CGSize(width: 0, height: 0)
        }
        
        let reward = rewardList.object(at: (indexPath as NSIndexPath).row) as! Reward
        
        let nameheight = BaseInfoUtil.getLabelHeight(15,
                                                     width: bound.width / 2 - 40,
                                                     message: reward.name)
        
        let height = nameheight + bound.width / 2 + 80
        return CGSize(width: (bound.width - 40) / 2, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInsets = UIEdgeInsetsMake(15, 15, 5, 15)
        return edgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView: UICollectionReusableView!
        
        if (kind == UICollectionElementKindSectionFooter)
        {
            footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView", for: indexPath)
            footer.backgroundColor = UIColor.white
            reusableView = footer;
        }
        return reusableView;
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPath = self.indexPathForItem(at: CGPoint(x: scrollView.contentOffset.x + 30, y: scrollView.contentOffset.y + screenHeight - 104))
        
        if indexPath != nil && (indexPath! as NSIndexPath).row >= self.rewardList.count / 2 - VISIBLE_REFRESH_COUNT && self.rewardList.count >= 10{
            loadMoreDelegate?.loadMore()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location:CGPoint! = touches.first?.location(in: self)
        
        print("\(location.x) : \(location.y)")
    }
}
