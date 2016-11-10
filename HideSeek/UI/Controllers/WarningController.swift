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
    var timer: Timer!
    var updateGoalDelegate: UpdateGoalDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        self.automaticallyAdjustsScrollViewInsets = false
        warningTableView.updateGoalDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer.invalidate()
        timer = nil
    }
    
    func callEverySecond() {
        let updateTime = getUpdateTime()
        WarningCache.instance.serverTime = WarningCache.instance.serverTime.addingTimeInterval(1)
        
        let durationDateComponents = (Calendar(identifier: Calendar.Identifier.gregorian) as NSCalendar).components( [.year, .month, .day, .hour, .minute, .second], from: WarningCache.instance.serverTime, to: updateTime, options: [])
        
        if durationDateComponents.hour! < 1 {
            hourLabel.textColor = UIColor.red
            minuteLabel.textColor = UIColor.red
            secondLabel.textColor = UIColor.red
            hourMinuteSplit.textColor = UIColor.red
            minuteSecondSplit.textColor = UIColor.red
        } else {
            hourLabel.textColor = UIColor.black
            minuteLabel.textColor = UIColor.black
            secondLabel.textColor = UIColor.black
            hourMinuteSplit.textColor = UIColor.black
            minuteSecondSplit.textColor = UIColor.black
        }
        hourLabel.text =  durationDateComponents.hour! > 9 ?
            "\(durationDateComponents.hour)" : "0\(durationDateComponents.hour)"
        minuteLabel.text =  durationDateComponents.minute! > 9 ?
            "\(durationDateComponents.minute)" : "0\(durationDateComponents.minute)"
        secondLabel.text = durationDateComponents.second! > 9 ?
            "\(durationDateComponents.second)" : "0\(durationDateComponents.second)"
    }
    
    func getUpdateTime() -> Date {
        let calendar = Calendar.current
        let startDate = Date()
        
        var dateComponents = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: startDate)
        dateComponents.day = dateComponents.day! + 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        return calendar.date(from: dateComponents)!
    }
    
    func refreshData() {
        let paramDict = NSMutableDictionary()
        _ = manager.POST(UrlParam.GET_DANGER_WARNING_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
                        let response = responseObject as! NSDictionary
                        
                        self.setInfoFromCallback(response)
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
        })
    }
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            WarningCache.instance.setWarnings(response["result"] as! NSDictionary)
            self.warningTableView.warningList = WarningCache.instance.cacheList
            self.warningTableView.reloadData()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(WarningController.callEverySecond), userInfo: nil, repeats: true)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func getWarnings(_ result: NSArray) -> NSMutableArray {
        let list = NSMutableArray()
        
        for warningItem in result {
            let warningInfo = warningItem as! NSDictionary
            let warning = Warning(goal: Goal(
                pkId: (warningInfo["pk_id"] as! NSString).longLongValue,
                latitude: (warningInfo["latitude"] as! NSString).doubleValue,
                longitude: (warningInfo["longitude"] as! NSString).doubleValue,
                orientation: BaseInfoUtil.getIntegerFromAnyObject(warningInfo["orientation"]),
                valid: BaseInfoUtil.getIntegerFromAnyObject(warningInfo["valid"]) == 1,
                type: Goal.GoalTypeEnum(rawValue: BaseInfoUtil.getIntegerFromAnyObject(warningInfo["type"]))!,
                showTypeName: warningInfo["show_type_name"] as? String,
                createBy: (warningInfo["create_by"] as! NSString).longLongValue,
                introduction: warningInfo["introduction"] as? String,
                score: BaseInfoUtil.getIntegerFromAnyObject(warningInfo["score"]),
                unionType: BaseInfoUtil.getIntegerFromAnyObject(warningInfo["union_type"])),
                createTime: warningInfo["create_time"] as! String)
            
            list.add(warning)
        }
        
        return list
    }
    
    func updateEndGoal(_ goalId: Int64) {
        updateGoalDelegate?.updateEndGoal(goalId)
        
        _ = self.navigationController?.popViewController(animated: true)
    }
}
