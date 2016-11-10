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
    
    @IBAction func cancelBtnClicked(_ sender: AnyObject) {
        delegate?.cancelChange()
    }
    
    @IBAction func okBtnClicked(_ sender: AnyObject) {
        delegate?.pickerDidChange()
    }
    
    func initWithStyle(_ pickerStyle: AreaPickerStyle, delegate: AreaPickerDelegate) {
        self.delegate = delegate
        self.pickerStyle = pickerStyle
        self.locatePicker.dataSource = self
        self.locatePicker.delegate = self
        
        if self.pickerStyle == AreaPickerStyle.areaPickerWithStateAndCityAndDistrict {
            provinces = NSArray.init(contentsOfFile: Bundle.main.path(forResource: "area.plist", ofType: nil)!)
            
            let province = provinces.object(at: 0) as! NSDictionary
            cities = province.object(forKey: "cities") as! NSArray
            
            let city = cities.object(at: 0) as! NSDictionary
            self.location.state = province.object(forKey: "state") as! NSString
            self.location.city = city.object(forKey: "city") as! NSString
            
            areas = city.object(forKey: "areas") as! NSArray
            
            if areas.count > 0 {
                self.location.district = areas.object(at: 0) as! NSString
            } else {
                self.location.district = ""
            }
        } else {
            provinces = NSArray.init(contentsOfFile: Bundle.main.path(forResource: "city.plist", ofType: nil)!)
            let province = provinces.object(at: 0) as! NSDictionary
            cities = province.object(forKey: "cities") as! NSArray
            
            self.location.state = province.object(forKey: "state") as! NSString
            self.location.city = cities.object(at: 0) as! NSString
        }
    }
    
    enum AreaPickerStyle : Int {
        case areaPickerWithStateAndCity = 1
        case areaPickerWithStateAndCityAndDistrict = 2
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if self.pickerStyle == AreaPickerStyle.areaPickerWithStateAndCityAndDistrict {
            return 3
        } else {
            return 2;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(component) {
        case 0:
            return provinces.count
        case 1:
            return cities.count
        case 2:
            if self.pickerStyle == AreaPickerStyle.areaPickerWithStateAndCityAndDistrict {
                return areas.count
            }
            break;
        default:
            return 0
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.pickerStyle == AreaPickerStyle.areaPickerWithStateAndCityAndDistrict {
            switch component {
            case 0:
                let province = provinces.object(at: row)
                return (province as AnyObject).object(forKey: "state") as? String
            case 1:
                let city = cities.object(at: row)
                return (city as AnyObject).object(forKey: "city") as? String
            case 2:
                if areas.count > 0 {
                    return areas.object(at: row) as? String
                }
                break;
            default:
                return ""
            }
        } else {
            switch component {
            case 0:
                let province = provinces.object(at: row)
                return (province as AnyObject).object(forKey: "state") as? String
            case 1:
                return cities.object(at: row) as? String
            default:
                return ""
            }
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.pickerStyle == AreaPickerStyle.areaPickerWithStateAndCityAndDistrict {
            switch component {
            case 0:
                var province = provinces.object(at: row) as! NSDictionary
                cities = province.object(forKey: "cities") as! NSArray
                
                self.locatePicker.selectRow(0, inComponent: 1, animated: true)
                self.locatePicker.reloadComponent(1)
                
                let city = cities.object(at: 0) as! NSDictionary
                areas = city.object(forKey: "areas") as! NSArray
                
                self.locatePicker.selectRow(0, inComponent: 2, animated: true)
                self.locatePicker.reloadComponent(2)
                
                province = provinces.object(at: row) as! NSDictionary
                self.location.state = province.object(forKey: "state") as! NSString
                self.location.city = city.object(forKey: "city") as! NSString
                
                if areas.count > 0 {
                    self.location.district = areas.object(at: 0) as! NSString
                } else {
                    self.location.district = ""
                }
                break;
            case 1:
                var city = cities.object(at: row) as! NSDictionary
                areas = city.object(forKey: "areas") as! NSArray
                self.locatePicker.selectRow(0, inComponent: 2, animated: true)
                self.locatePicker.reloadComponent(2)
                
                city = cities.object(at: row) as! NSDictionary
                self.location.city = city.object(forKey: "city") as! NSString
                
                if areas.count > 0 {
                    self.location.district = areas.object(at: 0) as! NSString
                } else {
                    self.location.district = ""
                }
                break;
            case 2:
                if areas.count > 0 {
                    self.location.district = areas.object(at: row) as! NSString
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
                let province = provinces.object(at: row) as! NSDictionary
                cities = province.object(forKey: "cities") as! NSArray
                self.locatePicker.selectRow(0, inComponent: 1, animated: true)
                self.locatePicker.reloadComponent(1)
                
                self.location.state = province.object(forKey: "state") as! NSString
                self.location.city = cities.object(at: 0) as! NSString
                break;
            case 1:
                self.location.city = cities.object(at: row) as! NSString
                break;
            default:
                break;
            }
        }
    }
}
