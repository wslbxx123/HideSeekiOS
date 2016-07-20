//
//  PurchaseCollectionView.swift
//  HideSeek
//
//  Created by apple on 7/20/16.
//  Copyright © 2016 mj. All rights reserved.
//

class PurchaseCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var cellIdentifier: String = "purchaseCell"
    var productList: NSArray!
    var bound: CGRect!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.dataSource = self
        self.registerClass(PurchaseCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.productList = NSArray()
        self.bound = UIScreen.mainScreen().bounds
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
            cell.backgroundColor = UIColor.whiteColor()
            cell.setName(product.name)
            cell.setImageUrl(product.imageUrl)
            cell.setPrice(product.price)
            cell.setPurchaseCount(product.purchaseCount)
            cell.setIntroduction(product.introduction)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let product = productList.objectAtIndex(indexPath.row) as! Product
        
        let nameheight = BaseInfoUtil.getLabelHeight(15,
                                                     width: bound.width / 2 - 40,
                                                     message: product.name)
        let introductionHeight = BaseInfoUtil.getLabelHeight(12,
                                                             width: bound.width / 2 - 40,
                                                             message: product.introduction)
        let height = nameheight + introductionHeight + bound.width / 2 + 30
        return CGSizeMake((bound.width - 40) / 2, height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let edgeInsets = UIEdgeInsetsMake(15, 15, 5, 15)
        return edgeInsets
    }
}