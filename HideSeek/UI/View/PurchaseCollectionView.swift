//
//  PurchaseCollectionView.swift
//  HideSeek
//
//  Created by apple on 7/20/16.
//  Copyright © 2016 mj. All rights reserved.
//

class PurchaseCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    let VISIBLE_REFRESH_COUNT = 3
    var cellIdentifier: String = "purchaseCell"
    var productList: NSMutableArray!
    var bound: CGRect!
    var screenHeight: CGFloat!
    var purchaseDelegate: PurchaseDelegate!
    var loadMoreDelegate: LoadMoreDelegate!
    var footer: UICollectionReusableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.dataSource = self
        self.registerClass(PurchaseCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.productList = NSMutableArray()
        self.bound = UIScreen.mainScreen().bounds
        self.screenHeight = bound.height
        
        self.delaysContentTouches = false
        BaseInfoUtil.cancelButtonDelay(self)
    }
    
    /**
    UICollectionViewDataSource
    **/
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productList.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! PurchaseCollectionViewCell
        
        if(indexPath.row < productList.count) {
            let product = productList.objectAtIndex(indexPath.row) as! Product
            cell.purchaseDelegate = purchaseDelegate
            cell.backgroundColor = UIColor.whiteColor()
            cell.product = product
            cell.setName(product.name)
            cell.setImageUrl(product.imageUrl)
            cell.setPrice(product.price)
            cell.setPurchaseCount(product.purchaseCount)
            cell.setIntroduction(product.introduction)
            cell.setPurchaseBtn()
        }
        BaseInfoUtil.cancelButtonDelay(cell)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let product = productList.objectAtIndex(indexPath.row) as! Product
        
        let nameheight = BaseInfoUtil.getLabelHeight(15,
                                                     width: bound.width / 2 - 40,
                                                     message: product.name)
        
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
        
        if indexPath != nil && indexPath!.row >= self.productList.count / 2 - VISIBLE_REFRESH_COUNT && self.productList.count >= 10{
            
            loadMoreDelegate?.loadMore()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location:CGPoint! = touches.first?.locationInView(self)
        
        print("\(location.x) : \(location.y)")
    }
}