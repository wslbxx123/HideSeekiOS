//
//  ExternalController.swift
//  HideSeek
//
//  Created by apple on 7/28/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class ExternalController: UIViewController, UISearchBarDelegate, HideKeyboardDelegate {
    @IBOutlet weak var cityTableView: ForeignCityTableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var selectRegionDelegate: SelectRegionDelegate!
    var showToastDelegate: ShowToastDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cityTableView.selectRegionDelegate = selectRegionDelegate
        let cityList = ForeignCityTableManager.instance.getAllCities()
        cityTableView.cityList = cityList
        cityTableView.alphaIndex = getAlphaIndexFromList(cityList)
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (!searchText.isEmpty) {
            cityTableView.cityList = ForeignCityTableManager.instance.searchCities(searchText)
            cityTableView.isSearching = true
            cityTableView.reloadData()
        } else {
            let cityList = ForeignCityTableManager.instance.getAllCities()
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
            let city = cityList[i] as! ForeignCity
            let pinyin = city.name as NSString
            let currentStr = pinyin.substring(to: 1).uppercased()
            
            var previewStr = ""
            if i >= 1 {
                let lastCity = cityList[i - 1] as! ForeignCity
                previewStr = (lastCity.name as NSString).substring(to: 1).uppercased()
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
