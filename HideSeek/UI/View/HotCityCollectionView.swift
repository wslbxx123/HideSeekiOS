//
//  HotCityCollectionView.swift
//  HideSeek
//
//  Created by apple on 7/30/16.
//  Copyright © 2016 mj. All rights reserved.
//

class HotCityCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var cellIdentifier: String = "hotCityCell"
    var hotCityList: NSArray!
    var bound: CGRect!
    var selectRegionDelegate: SelectRegionDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.hotCityList = NSArray()
        self.bound = UIScreen.mainScreen().bounds
        self.delegate = self
        self.dataSource = self
        self.registerClass(RecentCityCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.delaysContentTouches = false
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotCityList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! RecentCityCollectionViewCell
        
        if indexPath.row < hotCityList.count {
            let city = hotCityList.objectAtIndex(indexPath.row) as! DomesticCity
            cell.backgroundColor = UIColor.whiteColor()
            cell.city = city
            cell.setName(city.name)
            cell.selectRegionDelegate = selectRegionDelegate
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let edgeInsets = UIEdgeInsetsMake(10, 10, 5, 10)
        return edgeInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((bound.width  - 85) / 3, 40)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let city = hotCityList.objectAtIndex(indexPath.row) as! DomesticCity
        
        DomesticCityTableManager.instance.insertRecentCity(city)
        selectRegionDelegate?.regionSelected(city.name)
    }
    
    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        if view .isKindOfClass(UIButton) {
            return true
        }
        
        return super.touchesShouldCancelInContentView(view)
    }
}
