//
//  RecentCityCollectionView.swift
//  HideSeek
//
//  Created by apple on 7/29/16.
//  Copyright © 2016 mj. All rights reserved.
//

class RecentCityCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
{
    var cellIdentifier: String = "recentCityCell"
    var recentCityList: NSArray!
    var bound: CGRect!
    var selectRegionDelegate: SelectRegionDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.recentCityList = NSArray()
        self.bound = UIScreen.main.bounds
        self.delegate = self
        self.dataSource = self
        self.register(RecentCityCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.delaysContentTouches = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentCityList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! RecentCityCollectionViewCell
        
        if (indexPath as NSIndexPath).row < recentCityList.count {
            let city = recentCityList.object(at: (indexPath as NSIndexPath).row) as! DomesticCity
            cell.backgroundColor = UIColor.white
            cell.city = city
            cell.setName(city.name)
            cell.selectRegionDelegate = selectRegionDelegate
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInsets = UIEdgeInsetsMake(10, 10, 5, 10)
        return edgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (bound.width  - 85) / 3, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if recentCityList.count < (indexPath as NSIndexPath).row + 1 {
            return
        }
        
        let city = recentCityList.object(at: (indexPath as NSIndexPath).row) as! DomesticCity
        
        DomesticCityTableManager.instance.insertRecentCity(city)
        selectRegionDelegate?.regionSelected(city.name)
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view .isKind(of: UIButton.self) {
            return true
        }
        
        return super.touchesShouldCancel(in: view)
    }
}
