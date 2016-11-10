//
//  InternalController.swift
//  HideSeek
//
//  Created by apple on 7/28/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class InternalController: UIViewController, UISearchBarDelegate, HideKeyboardDelegate{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityTableView: DomesticCityTableView!
    var selectRegionDelegate: SelectRegionDelegate!
    var showToastDelegate: ShowToastDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityTableView.selectRegionDelegate = selectRegionDelegate
        let cityList = DomesticCityTableManager.instance.getAllCities()
        cityTableView.cityList = cityList
        cityTableView.alphaIndex = getAlphaIndexFromList(cityList)
        cityTableView.recentCityList = DomesticCityTableManager.instance.getRecentCities()
        cityTableView.hotCityList = getHotCityList()
        cityTableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        cityTableView.reloadData()
        cityTableView.showToastDelegate = showToastDelegate
        cityTableView.hideKeyboardDelegate = self
        searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getHotCityList() -> NSMutableArray {
        let hotCityList = NSMutableArray()
        
        hotCityList.add(DomesticCity(name: "上海", pinYin: "Shanghai"))
        hotCityList.add(DomesticCity(name: "北京", pinYin: "Beijing"))
        hotCityList.add(DomesticCity(name: "广州", pinYin: "Guangzhou"))
        hotCityList.add(DomesticCity(name: "深圳", pinYin: "Shenzhen"))
        hotCityList.add(DomesticCity(name: "武汉", pinYin: "Wuhan"))
        hotCityList.add(DomesticCity(name: "天津", pinYin: "Tianjin"))
        hotCityList.add(DomesticCity(name: "西安", pinYin: "Xian"))
        hotCityList.add(DomesticCity(name: "南京", pinYin: "Nanjing"))
        hotCityList.add(DomesticCity(name: "杭州", pinYin: "Hangzhou"))
        hotCityList.add(DomesticCity(name: "成都", pinYin: "Chengdu"))
        hotCityList.add(DomesticCity(name: "重庆", pinYin: "Chongqing"))
        
        return hotCityList
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (!searchText.isEmpty) {
            cityTableView.cityList = DomesticCityTableManager.instance.searchCities(searchText)
            cityTableView.isSearching = true
            cityTableView.reloadData()
        } else {
            let cityList = DomesticCityTableManager.instance.getAllCities()
            cityTableView.cityList = cityList
            cityTableView.alphaIndex = getAlphaIndexFromList(cityList)
            cityTableView.isSearching = false
            cityTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func getAlphaIndexFromList(_ cityList: NSMutableArray) -> NSMutableDictionary{
        let alphaIndex = NSMutableDictionary()
        
        for i in 0...cityList.count - 1 {
            let city = cityList[i] as! DomesticCity
            let pinyin = city.pinYin as NSString
            let currentStr = pinyin.substring(to: 1).uppercased()
            
            var previewStr = ""
            if i >= 1 {
                let lastCity = cityList[i - 1] as! DomesticCity
                previewStr = (lastCity.pinYin as NSString).substring(to: 1).uppercased()
            }
            
            if previewStr != currentStr {
                alphaIndex[currentStr] = i
            }
        }
        return alphaIndex
    }
    
    func hideKeyboard() {
        searchBar.resignFirstResponder()
    }
}
