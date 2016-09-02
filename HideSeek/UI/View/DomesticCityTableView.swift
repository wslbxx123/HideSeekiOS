//
//  DomesticCityTableView.swift
//  HideSeek
//
//  Created by apple on 7/28/16.
//  Copyright © 2016 mj. All rights reserved.
//
import UIKit

class DomesticCityTableView: UITableView, UITableViewDataSource, UITableViewDelegate, AMapLocationManagerDelegate, AMapSearchDelegate {
    let TAG_CITY_NAME_LABEL = 1
    let TAG_LOCATION_BTN = 2
    let TAG_RECENT_CITY_COLLECTIONVIEW = 3
    let TAG_HOT_CITY_COLLECTIONVIEW = 4
    let TAG_ALPHA_LABEL = 5
    let TAG_ALPHA_VIEW = 6
    var cityList = NSMutableArray()
    var recentCityList = NSMutableArray()
    var hotCityList = NSMutableArray()
    var alphaIndex: NSDictionary = NSDictionary()
    var search: AMapSearchAPI!
    var region: String!
    var locationProcess: LocationProcessEnum = LocationProcessEnum.locating
    var locationManager: AMapLocationManager!
    var selectRegionDelegate: SelectRegionDelegate!
    var isSearching: Bool = false
    var showToastDelegate: ShowToastDelegate!
    var hideKeyboardDelegate: HideKeyboardDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        
        self.search = AMapSearchAPI()
        self.search.delegate = self
        self.locationManager = AMapLocationManager()
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        self.delaysContentTouches = false
        self.sectionIndexColor = UIColor.blackColor()
        self.sectionIndexBackgroundColor = BaseInfoUtil.stringToRGB("#f0f0f0")
        
        BaseInfoUtil.cancelButtonDelay(self)
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        let toBeReturned = NSMutableArray()
        if !isSearching {
            toBeReturned.addObject("定位")
            toBeReturned.addObject("最近")
            toBeReturned.addObject("热门")
            toBeReturned.addObject("全部")
            
            for index in 0...25 {
                let randomNum = 65 + index
                let char = Character(UnicodeScalar(randomNum))
                toBeReturned.addObject(String(char))
            }
        }
        
        return toBeReturned.copy() as? [String]
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if index < 4 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: 0, inSection: index), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        } else {
            let position = alphaIndex[title]
            
            if (position != nil) {
                tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: position as! Int, inSection: 4), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
        }
        
        return index
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch(indexPath.section) {
        case 0:
            return 62
        case 1:
            return 100
        case 2:
            return 250
        case 3:
            return 62
        case 4:
            let showAlpha = alphaIndex.allValues.contains({ value in
                return value as! Int == indexPath.row
            })
           
            if showAlpha && !isSearching{
                return 120
            } else {
                return 62
            }
        default:
            return 62
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch(indexPath.section) {
        case 0:
            cell = self.dequeueReusableCellWithIdentifier("locationCell")! as UITableViewCell
            let cityNameLabel = cell.viewWithTag(TAG_CITY_NAME_LABEL) as! UILabel
            let locationBtn = cell.viewWithTag(TAG_LOCATION_BTN) as! UIButton
            
            cityNameLabel.text = region
            locationBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
            locationBtn.layer.cornerRadius = 5
            locationBtn.layer.masksToBounds = true
            
            switch(locationProcess) {
            case .locating:
                locationBtn.hidden = true
                cityNameLabel.text = NSLocalizedString("LOCATING", comment: "locating")
                break;
            case .located:
                locationBtn.hidden = false
                locationBtn.setTitle(region, forState: UIControlState.Normal)
                cityNameLabel.text = NSLocalizedString("CURRENT_CITY", comment: "Current City")
                locationBtn.addTarget(self, action: #selector(DomesticCityTableView.locationCityClicked(_:)), forControlEvents: UIControlEvents.TouchDown)
                break;
            case .failedLocated:
                locationBtn.hidden = false
                locationBtn.setTitle(NSLocalizedString("RE_LOCATE", comment: "re-locate"), forState: UIControlState.Normal)
                cityNameLabel.text = NSLocalizedString("FAILED_TO_LOCATE", comment: "Failed to locate")
                break
            }
            
            break;
        case 1:
            cell = self.dequeueReusableCellWithIdentifier("recentCityCell")! as UITableViewCell
            let recentCityTableView = cell.viewWithTag(TAG_RECENT_CITY_COLLECTIONVIEW) as! RecentCityCollectionView
            
            recentCityTableView.selectRegionDelegate = selectRegionDelegate
            recentCityTableView.recentCityList = recentCityList
            recentCityTableView.reloadData()
            break;
        case 2:
            cell = self.dequeueReusableCellWithIdentifier("hotCityCell")! as UITableViewCell
            let hotCityTableView = cell.viewWithTag(TAG_HOT_CITY_COLLECTIONVIEW) as! HotCityCollectionView
            
            hotCityTableView.selectRegionDelegate = selectRegionDelegate
            hotCityTableView.hotCityList = hotCityList
            hotCityTableView.reloadData()
            break;
        case 3:
            cell = self.dequeueReusableCellWithIdentifier("cityTitleCell")! as UITableViewCell
            break;
        case 4:
            cell = self.dequeueReusableCellWithIdentifier("domesticCityCell")! as UITableViewCell
            let city = cityList.objectAtIndex(indexPath.row) as! DomesticCity
            
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
            break;
        default:
            cell = UITableViewCell()
        }
        
        BaseInfoUtil.cancelButtonDelay(cell)
        return cell
    }
    
    func locationCityClicked(button: UIButton) {
        if button.currentTitle != NSLocalizedString("RE_LOCATE", comment: "re-locate")
            || !button.hidden {
            let city = DomesticCity(name: button.currentTitle!, pinYin: PinYinUtil.converterToPinyin(button.currentTitle!))
            DomesticCityTableManager.instance.insertRecentCity(city)
            selectRegionDelegate?.regionSelected(city.name)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 4:
            return cityList.count
        default:
            if isSearching {
                return 0
            } else {
                return 1
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 4 {
            let city = cityList.objectAtIndex(indexPath.row) as! DomesticCity
            
            DomesticCityTableManager.instance.insertRecentCity(city)
            
            self.selectRegionDelegate?.regionSelected(city.name)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        hideKeyboardDelegate?.hideKeyboard()
        
        let indexPath = self.indexPathForRowAtPoint(CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y))
        
        if indexPath != nil {
            let showAlpha = alphaIndex.allValues.contains({ value in
                return value as! Int == indexPath!.row
            })
            
            if showAlpha && !isSearching && indexPath?.section == 4 {
                let alpha = alphaIndex.allKeysForObject(indexPath!.row)[0]
                
                showToastDelegate?.showToast(alpha as! String)
            }
        }
    }
    
    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        if view.isKindOfClass(UIButton) {
            return true
        }
        
        return super.touchesShouldCancelInContentView(view)
    }
    
    func amapLocationManager(manager: AMapLocationManager!, didUpdateLocation location: CLLocation!) {
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = AMapGeoPoint.locationWithLatitude(CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude))
        
        search.AMapReGoecodeSearch(regeo)
    }
    
    func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if response.regeocode != nil {
            var city = response.regeocode.addressComponent.city
            
            if city == nil || city.characters.count == 0 {
                city = response.regeocode.addressComponent.province
            }
            
            if city != region {
                region = city
                
                let tempRegion = region as NSString
                if tempRegion.rangeOfString("市").location == tempRegion.length - 1 {
                    region = tempRegion.substringToIndex(tempRegion.length - 1)
                }
            }
            
            locationProcess = LocationProcessEnum.located
        } else {
            locationProcess = LocationProcessEnum.failedLocated
        }
        
        self.reloadData()
    }
    
    enum LocationProcessEnum : Int {
        case locating = 1
        case located = 2
        case failedLocated = 3
    }
}
