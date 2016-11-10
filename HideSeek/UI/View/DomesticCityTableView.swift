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
        self.sectionIndexColor = UIColor.black
        self.sectionIndexBackgroundColor = BaseInfoUtil.stringToRGB("#f0f0f0")
        
        BaseInfoUtil.cancelButtonDelay(self)
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let toBeReturned = NSMutableArray()
        if !isSearching {
            toBeReturned.add("定位")
            toBeReturned.add("最近")
            toBeReturned.add("热门")
            toBeReturned.add("全部")
            
            for index in 0...25 {
                let randomNum = 65 + index
                let char = Character(UnicodeScalar(randomNum)!)
                toBeReturned.add(String(char))
            }
        }
        
        return toBeReturned.copy() as? [String]
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if index < 4 {
            tableView.scrollToRow(at: IndexPath(item: 0, section: index), at: UITableViewScrollPosition.top, animated: true)
        } else {
            let position = alphaIndex[title]
            
            if (position != nil) {
                tableView.scrollToRow(at: IndexPath(item: position as! Int, section: 4), at: UITableViewScrollPosition.top, animated: true)
            }
        }
        
        return index
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch((indexPath as NSIndexPath).section) {
        case 0:
            return 62
        case 1:
            return 100
        case 2:
            return 250
        case 3:
            return 62
        case 4:
            let showAlpha = alphaIndex.allValues.contains(where: { value in
                return value as! Int == (indexPath as NSIndexPath).row
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch((indexPath as NSIndexPath).section) {
        case 0:
            cell = self.dequeueReusableCell(withIdentifier: "locationCell")! as UITableViewCell
            let cityNameLabel = cell.viewWithTag(TAG_CITY_NAME_LABEL) as! UILabel
            let locationBtn = cell.viewWithTag(TAG_LOCATION_BTN) as! UIButton
            
            cityNameLabel.text = region
            locationBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
            locationBtn.layer.cornerRadius = 5
            locationBtn.layer.masksToBounds = true
            
            switch(locationProcess) {
            case .locating:
                locationBtn.isHidden = true
                cityNameLabel.text = NSLocalizedString("LOCATING", comment: "locating")
                break;
            case .located:
                locationBtn.isHidden = false
                locationBtn.setTitle(region, for: UIControlState())
                cityNameLabel.text = NSLocalizedString("CURRENT_CITY", comment: "Current City")
                locationBtn.addTarget(self, action: #selector(DomesticCityTableView.locationCityClicked(_:)), for: UIControlEvents.touchDown)
                break;
            case .failedLocated:
                locationBtn.isHidden = false
                locationBtn.setTitle(NSLocalizedString("RE_LOCATE", comment: "re-locate"), for: UIControlState())
                cityNameLabel.text = NSLocalizedString("FAILED_TO_LOCATE", comment: "Failed to locate")
                break
            }
            
            break;
        case 1:
            cell = self.dequeueReusableCell(withIdentifier: "recentCityCell")! as UITableViewCell
            let recentCityTableView = cell.viewWithTag(TAG_RECENT_CITY_COLLECTIONVIEW) as! RecentCityCollectionView
            
            recentCityTableView.selectRegionDelegate = selectRegionDelegate
            recentCityTableView.recentCityList = recentCityList
            recentCityTableView.reloadData()
            break;
        case 2:
            cell = self.dequeueReusableCell(withIdentifier: "hotCityCell")! as UITableViewCell
            let hotCityTableView = cell.viewWithTag(TAG_HOT_CITY_COLLECTIONVIEW) as! HotCityCollectionView
            
            hotCityTableView.selectRegionDelegate = selectRegionDelegate
            hotCityTableView.hotCityList = hotCityList
            hotCityTableView.reloadData()
            break;
        case 3:
            cell = self.dequeueReusableCell(withIdentifier: "cityTitleCell")! as UITableViewCell
            break;
        case 4:
            cell = self.dequeueReusableCell(withIdentifier: "domesticCityCell")! as UITableViewCell
            if cityList.count < (indexPath as NSIndexPath).row + 1 {
                return cell
            }
            
            let city = cityList.object(at: (indexPath as NSIndexPath).row) as! DomesticCity
            
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
            break;
        default:
            cell = UITableViewCell()
        }
        
        BaseInfoUtil.cancelButtonDelay(cell)
        return cell
    }
    
    func locationCityClicked(_ button: UIButton) {
        if button.currentTitle != NSLocalizedString("RE_LOCATE", comment: "re-locate")
            || !button.isHidden {
            let city = DomesticCity(name: button.currentTitle!, pinYin: PinYinUtil.converterToPinyin(button.currentTitle!))
            DomesticCityTableManager.instance.insertRecentCity(city)
            selectRegionDelegate?.regionSelected(city.name)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 4 {
            if cityList.count < (indexPath as NSIndexPath).row + 1 {
                return
            }
            
            let city = cityList.object(at: (indexPath as NSIndexPath).row) as! DomesticCity
            
            DomesticCityTableManager.instance.insertRecentCity(city)
            
            self.selectRegionDelegate?.regionSelected(city.name)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideKeyboardDelegate?.hideKeyboard()
        
        let indexPath = self.indexPathForRow(at: CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y))
        
        if indexPath != nil {
            let showAlpha = alphaIndex.allValues.contains(where: { value in
                return value as! Int == (indexPath! as NSIndexPath).row
            })
            
            if showAlpha && !isSearching && (indexPath as NSIndexPath?)?.section == 4 {
                let alpha = alphaIndex.allKeys(for: (indexPath! as NSIndexPath).row)[0]
                
                showToastDelegate?.showToast(alpha as! String)
            }
        }
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: UIButton.self) {
            return true
        }
        
        return super.touchesShouldCancel(in: view)
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = AMapGeoPoint.location(withLatitude: CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude))
        
        search.aMapReGoecodeSearch(regeo)
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if response.regeocode != nil {
            var city = response.regeocode.addressComponent.city
            
            if city == nil || city?.characters.count == 0 {
                city = response.regeocode.addressComponent.province
            }
            
            if city != region {
                region = city
                
                let tempRegion = region as NSString
                if tempRegion.range(of: "市").location == tempRegion.length - 1 {
                    region = tempRegion.substring(to: tempRegion.length - 1)
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
