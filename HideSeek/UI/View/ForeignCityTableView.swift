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
        self.sectionIndexColor = UIColor.black
        self.sectionIndexBackgroundColor = BaseInfoUtil.stringToRGB("#f0f0f0")
        
        BaseInfoUtil.cancelButtonDelay(self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let toBeReturned = NSMutableArray()
        
        for index in 0...25 {
            let randomNum = 65 + index
            let char = Character(UnicodeScalar(randomNum)!)
            toBeReturned.add(String(char))
        }
        return toBeReturned.copy() as? [String]
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        let position = alphaIndex[title]
        
        if (position != nil) {
            tableView.scrollToRow(at: IndexPath(item: position as! Int, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
        
        return index
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let showAlpha = alphaIndex.allValues.contains(where: { value in
            return value as! Int == (indexPath as NSIndexPath).row
        })
        
        if showAlpha && !isSearching {
            return 120
        } else {
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: "foreignCityCell")! as UITableViewCell
        if cityList.count < (indexPath as NSIndexPath).row + 1 {
            return cell
        }
        
        let city = cityList.object(at: (indexPath as NSIndexPath).row) as! ForeignCity
        
        let showAlpha = alphaIndex.allValues.contains(where: { value in
            return value as! Int == (indexPath as NSIndexPath).row
        })
        let cityNameLabel = cell.viewWithTag(TAG_CITY_NAME_LABEL) as! UILabel
        let alphaLabel = cell.viewWithTag(TAG_ALPHA_LABEL) as! UILabel
        let alphaView = cell.viewWithTag(TAG_ALPHA_VIEW)
        
        cityNameLabel.text = city.name
        
        if showAlpha && !isSearching {
            alphaView!.isHidden = false
            alphaLabel.text = alphaIndex.allKeys(for: (indexPath as NSIndexPath).row)[0] as? String
        } else {
            alphaView!.isHidden = true
            alphaLabel.text = ""
        }
        
        BaseInfoUtil.cancelButtonDelay(cell)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideKeyboardDelegate?.hideKeyboard()
        
        let indexPath = self.indexPathForRow(at: CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y))
        
        if indexPath != nil {
            let showAlpha = alphaIndex.allValues.contains(where: { value in
                return value as! Int == (indexPath! as NSIndexPath).row
            })
            
            if showAlpha && !isSearching {
                let alpha = alphaIndex.allKeys(for: (indexPath! as NSIndexPath).row)[0]
                
                showToastDelegate?.showToast(alpha as! String)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cityList.count < (indexPath as NSIndexPath).row + 1 {
            return
        }
        
        let city = cityList.object(at: (indexPath as NSIndexPath).row) as! ForeignCity
        
        self.selectRegionDelegate?.regionSelected(city.name)
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: UIButton.self) {
            return true
        }
        
        return super.touchesShouldCancel(in: view)
    }

}
