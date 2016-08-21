//
//  InternalController.swift
//  HideSeek
//
//  Created by apple on 7/28/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class InternalController: UIViewController, UISearchBarDelegate{
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
        cityTableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        cityTableView.reloadData()
        cityTableView.showToastDelegate = showToastDelegate
        searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getHotCityList() -> NSMutableArray {
        let hotCityList = NSMutableArray()
        
        hotCityList.addObject(DomesticCity(name: "上海", pinYin: "Shanghai"))
        hotCityList.addObject(DomesticCity(name: "北京", pinYin: "Beijing"))
        hotCityList.addObject(DomesticCity(name: "广州", pinYin: "Guangzhou"))
        hotCityList.addObject(DomesticCity(name: "深圳", pinYin: "Shenzhen"))
        hotCityList.addObject(DomesticCity(name: "武汉", pinYin: "Wuhan"))
        hotCityList.addObject(DomesticCity(name: "天津", pinYin: "Tianjin"))
        hotCityList.addObject(DomesticCity(name: "西安", pinYin: "Xian"))
        hotCityList.addObject(DomesticCity(name: "南京", pinYin: "Nanjing"))
        hotCityList.addObject(DomesticCity(name: "杭州", pinYin: "Hangzhou"))
        hotCityList.addObject(DomesticCity(name: "成都", pinYin: "Chengdu"))
        hotCityList.addObject(DomesticCity(name: "重庆", pinYin: "Chongqing"))
        
        return hotCityList
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func getAlphaIndexFromList(cityList: NSMutableArray) -> NSMutableDictionary{
        let alphaIndex = NSMutableDictionary()
        
        for i in 0...cityList.count - 1 {
            let city = cityList[i] as! DomesticCity
            let pinyin = city.pinYin as NSString
            let currentStr = pinyin.substringToIndex(1).uppercaseString
            
            var previewStr = ""
            if i >= 1 {
                let lastCity = cityList[i - 1] as! DomesticCity
                previewStr = (lastCity.pinYin as NSString).substringToIndex(1).uppercaseString
            }
            
            if previewStr != currentStr {
                alphaIndex[currentStr] = i
            }
        }
        return alphaIndex
    }
}
