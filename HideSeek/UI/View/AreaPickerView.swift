//
//  AreaPickerView.swift
//  HideSeek
//
//  Created by apple on 9/10/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class AreaPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var locatePicker: UIPickerView!
    var delegate: AreaPickerDelegate!
    var pickerStyle: AreaPickerStyle!
    var provinces: NSArray!
    var cities: NSArray!
    var areas: NSArray!
    
    var _location: Location!
    var location: Location {
        if _location == nil {
            _location = Location()
        }
        
        return _location
    }
    
    @IBAction func cancelBtnClicked(sender: AnyObject) {
        delegate?.cancelChange()
    }
    
    @IBAction func okBtnClicked(sender: AnyObject) {
        delegate?.pickerDidChange()
    }
    
    func initWithStyle(pickerStyle: AreaPickerStyle, delegate: AreaPickerDelegate) {
        self.delegate = delegate
        self.pickerStyle = pickerStyle
        self.locatePicker.dataSource = self
        self.locatePicker.delegate = self
        
        if self.pickerStyle == AreaPickerStyle.AreaPickerWithStateAndCityAndDistrict {
            provinces = NSArray.init(contentsOfFile: NSBundle.mainBundle().pathForResource("area.plist", ofType: nil)!)
            
            let province = provinces.objectAtIndex(0) as! NSDictionary
            cities = province.objectForKey("cities") as! NSArray
            
            let city = cities.objectAtIndex(0) as! NSDictionary
            self.location.state = province.objectForKey("state") as! NSString
            self.location.city = city.objectForKey("city") as! NSString
            
            areas = city.objectForKey("areas") as! NSArray
            
            if areas.count > 0 {
                self.location.district = areas.objectAtIndex(0) as! NSString
            } else {
                self.location.district = ""
            }
        } else {
            provinces = NSArray.init(contentsOfFile: NSBundle.mainBundle().pathForResource("city.plist", ofType: nil)!)
            let province = provinces.objectAtIndex(0) as! NSDictionary
            cities = province.objectForKey("cities") as! NSArray
            
            self.location.state = province.objectForKey("state") as! NSString
            self.location.city = cities.objectAtIndex(0) as! NSString
        }
    }
    
    enum AreaPickerStyle : Int {
        case AreaPickerWithStateAndCity = 1
        case AreaPickerWithStateAndCityAndDistrict = 2
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if self.pickerStyle == AreaPickerStyle.AreaPickerWithStateAndCityAndDistrict {
            return 3
        } else {
            return 2;
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(component) {
        case 0:
            return provinces.count
        case 1:
            return cities.count
        case 2:
            if self.pickerStyle == AreaPickerStyle.AreaPickerWithStateAndCityAndDistrict {
                return areas.count
            }
            break;
        default:
            return 0
        }
        
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.pickerStyle == AreaPickerStyle.AreaPickerWithStateAndCityAndDistrict {
            switch component {
            case 0:
                let province = provinces.objectAtIndex(row)
                return province.objectForKey("state") as? String
            case 1:
                let city = cities.objectAtIndex(row)
                return city.objectForKey("city") as? String
            case 2:
                if areas.count > 0 {
                    return areas.objectAtIndex(row) as? String
                }
                break;
            default:
                return ""
            }
        } else {
            switch component {
            case 0:
                let province = provinces.objectAtIndex(row)
                return province.objectForKey("state") as? String
            case 1:
                return cities.objectAtIndex(row) as? String
            default:
                return ""
            }
        }
        
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.pickerStyle == AreaPickerStyle.AreaPickerWithStateAndCityAndDistrict {
            switch component {
            case 0:
                var province = provinces.objectAtIndex(row) as! NSDictionary
                cities = province.objectForKey("cities") as! NSArray
                
                self.locatePicker.selectRow(0, inComponent: 1, animated: true)
                self.locatePicker.reloadComponent(1)
                
                let city = cities.objectAtIndex(0) as! NSDictionary
                areas = city.objectForKey("areas") as! NSArray
                
                self.locatePicker.selectRow(0, inComponent: 2, animated: true)
                self.locatePicker.reloadComponent(2)
                
                province = provinces.objectAtIndex(row) as! NSDictionary
                self.location.state = province.objectForKey("state") as! NSString
                self.location.city = city.objectForKey("city") as! NSString
                
                if areas.count > 0 {
                    self.location.district = areas.objectAtIndex(0) as! NSString
                } else {
                    self.location.district = ""
                }
                break;
            case 1:
                var city = cities.objectAtIndex(row) as! NSDictionary
                areas = city.objectForKey("areas") as! NSArray
                self.locatePicker.selectRow(0, inComponent: 2, animated: true)
                self.locatePicker.reloadComponent(2)
                
                city = cities.objectAtIndex(row) as! NSDictionary
                self.location.city = city.objectForKey("city") as! NSString
                
                if areas.count > 0 {
                    self.location.district = areas.objectAtIndex(0) as! NSString
                } else {
                    self.location.district = ""
                }
                break;
            case 2:
                if areas.count > 0 {
                    self.location.district = areas.objectAtIndex(row) as! NSString
                } else {
                    self.location.district = ""
                }
                break;
            default:
                break;
            }
        } else {
            switch component {
            case 0:
                let province = provinces.objectAtIndex(row) as! NSDictionary
                cities = province.objectForKey("cities") as! NSArray
                self.locatePicker.selectRow(0, inComponent: 1, animated: true)
                self.locatePicker.reloadComponent(1)
                
                self.location.state = province.objectForKey("state") as! NSString
                self.location.city = cities.objectAtIndex(0) as! NSString
                break;
            case 1:
                self.location.city = cities.objectAtIndex(row) as! NSString
                break;
            default:
                break;
            }
        }
    }
}
