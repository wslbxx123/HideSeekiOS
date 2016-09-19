//
//  WarningController.swift
//  HideSeek
//
//  Created by apple on 8/25/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class WarningController: UIViewController, UpdateGoalDelegate {
    let HtmlType = "text/html"
    @IBOutlet weak var warningTableView: WarningTableView!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var hourMinuteSplit: UILabel!
    @IBOutlet weak var minuteSecondSplit: UILabel!
    
    var manager: CustomRequestManager!
    var timer: NSTimer!
    var updateGoalDelegate: UpdateGoalDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        self.automaticallyAdjustsScrollViewInsets = false
        warningTableView.updateGoalDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer.invalidate()
        timer = nil
    }
    
    func callEverySecond() {
        let updateTime = getUpdateTime()
        WarningCache.instance.serverTime = WarningCache.instance.serverTime.dateByAddingTimeInterval(1)
        
        let durationDateComponents = NSCalendar(identifier: NSCalendarIdentifierGregorian)!.components( [.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: WarningCache.instance.serverTime, toDate: updateTime, options: [])
        
        if durationDateComponents.hour < 1 {
            hourLabel.textColor = UIColor.redColor()
            minuteLabel.textColor = UIColor.redColor()
            secondLabel.textColor = UIColor.redColor()
            hourMinuteSplit.textColor = UIColor.redColor()
            minuteSecondSplit.textColor = UIColor.redColor()
        } else {
            hourLabel.textColor = UIColor.blackColor()
            minuteLabel.textColor = UIColor.blackColor()
            secondLabel.textColor = UIColor.blackColor()
            hourMinuteSplit.textColor = UIColor.blackColor()
            minuteSecondSplit.textColor = UIColor.blackColor()
        }
        hourLabel.text =  durationDateComponents.hour > 9 ?
            "\(durationDateComponents.hour)" : "0\(durationDateComponents.hour)"
        minuteLabel.text =  durationDateComponents.minute > 9 ?
            "\(durationDateComponents.minute)" : "0\(durationDateComponents.minute)"
        secondLabel.text = durationDateComponents.second > 9 ?
            "\(durationDateComponents.second)" : "0\(durationDateComponents.second)"
    }
    
    func getUpdateTime() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let startDate = NSDate()
        
        let dateComponents = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: startDate)
        dateComponents.day += 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        return calendar.dateFromComponents(dateComponents)!
    }
    
    func refreshData() {
        let paramDict = NSMutableDictionary()
        manager.POST(UrlParam.GET_DANGER_WARNING_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
                        let response = responseObject as! NSDictionary
                        
                        self.setInfoFromCallback(response)
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
        })
    }
    
    func setInfoFromCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            WarningCache.instance.setWarnings(response["result"] as! NSDictionary)
            self.warningTableView.warningList = WarningCache.instance.cacheList
            self.warningTableView.reloadData()
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(WarningController.callEverySecond), userInfo: nil, repeats: true)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func getWarnings(result: NSArray) -> NSMutableArray {
        let list = NSMutableArray()
        
        for warningItem in result {
            let warningInfo = warningItem as! NSDictionary
            let warning = Warning(goal: Goal(
                pkId: (warningInfo["pk_id"] as! NSString).longLongValue,
                latitude: (warningInfo["latitude"] as! NSString).doubleValue,
                longitude: (warningInfo["longitude"] as! NSString).doubleValue,
                orientation: (warningInfo["orientation"] as! NSString).integerValue,
                valid: (warningInfo["valid"] as! NSString).integerValue == 1,
                type: Goal.GoalTypeEnum(rawValue: (warningInfo["type"] as! NSString).integerValue)!,
                showTypeName: warningInfo["show_type_name"] as? String,
                createBy: (warningInfo["create_by"] as! NSString).longLongValue,
                introduction: warningInfo["introduction"] as? String,
                score: BaseInfoUtil.getIntegerFromAnyObject(warningInfo["score"]),
                unionType: (warningInfo["union_type"] as! NSString).integerValue),
                createTime: warningInfo["create_time"] as! String)
            
            list.addObject(warning)
        }
        
        return list
    }
    
    func updateEndGoal(goalId: Int64) {
        updateGoalDelegate?.updateEndGoal(goalId)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}
