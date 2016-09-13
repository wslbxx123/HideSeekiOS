//
//  ForeignCityTableView.swift
//  HideSeek
//
//  Created by apple on 7/30/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import MBProgressHUD

class ForeignCityTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    let TAG_CITY_NAME_LABEL = 1
    let TAG_ALPHA_LABEL = 2
    let TAG_ALPHA_VIEW = 3
    
    var cityList = NSMutableArray()
    var alphaIndex: NSDictionary = NSDictionary()
    var selectRegionDelegate: SelectRegionDelegate!
    var region: String!
    var isSearching: Bool = false
    var showToastDelegate: ShowToastDelegate!
    var hideKeyboardDelegate: HideKeyboardDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        
        self.delaysContentTouches = false
        self.sectionIndexColor = UIColor.blackColor()
        self.sectionIndexBackgroundColor = BaseInfoUtil.stringToRGB("#f0f0f0")
        
        BaseInfoUtil.cancelButtonDelay(self)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        let toBeReturned = NSMutableArray()
        
        for index in 0...25 {
            let randomNum = 65 + index
            let char = Character(UnicodeScalar(randomNum))
            toBeReturned.addObject(String(char))
        }
        return toBeReturned.copy() as? [String]
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        let position = alphaIndex[title]
        
        if (position != nil) {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: position as! Int, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
        
        return index
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let showAlpha = alphaIndex.allValues.contains({ value in
            return value as! Int == indexPath.row
        })
        
        if showAlpha && !isSearching {
            return 120
        } else {
            return 65
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCellWithIdentifier("foreignCityCell")! as UITableViewCell
        if cityList.count < indexPath.row + 1 {
            return cell
        }
        
        let city = cityList.objectAtIndex(indexPath.row) as! ForeignCity
        
        let showAlpha = alphaIndex.allValues.contains({ value in
            return value as! Int == indexPath.row
        })
        let cityNameLabel = cell.viewWithTag(TAG_CITY_NAME_LABEL) as! UILabel
        let alphaLabel = cell.viewWithTag(TAG_ALPHA_LABEL) as! UILabel
        let alphaView = cell.viewWithTag(TAG_ALPHA_VIEW)
        
        cityNameLabel.text = city.name
        
        if showAlpha && !isSearching {
            alphaView!.hidden = false
            alphaLabel.text = alphaIndex.allKeysForObject(indexPath.row)[0] as? String
        } else {
            alphaView!.hidden = true
            alphaLabel.text = ""
        }
        
        BaseInfoUtil.cancelButtonDelay(cell)
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        hideKeyboardDelegate?.hideKeyboard()
        
        let indexPath = self.indexPathForRowAtPoint(CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y))
        
        if indexPath != nil {
            let showAlpha = alphaIndex.allValues.contains({ value in
                return value as! Int == indexPath!.row
            })
            
            if showAlpha && !isSearching {
                let alpha = alphaIndex.allKeysForObject(indexPath!.row)[0]
                
                showToastDelegate?.showToast(alpha as! String)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if cityList.count < indexPath.row + 1 {
            return
        }
        
        let city = cityList.objectAtIndex(indexPath.row) as! ForeignCity
        
        self.selectRegionDelegate?.regionSelected(city.name)
    }
    
    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        if view.isKindOfClass(UIButton) {
            return true
        }
        
        return super.touchesShouldCancelInContentView(view)
    }

}
