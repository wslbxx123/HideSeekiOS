//
//  ComboxPickerView.swift
//  HideSeek
//
//  Created by apple on 7/26/16.
//  Copyright © 2016 mj. All rights reserved.
//

class ComboxPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    var items: NSMutableArray!
    var pickerViewDelegate: PickerViewDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.dataSource = self
        items = NSMutableArray()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let item = items[row]
        
        return item as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel
        
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel!.font = UIFont.systemFont(ofSize: 20)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        pickerLabel?.text = self.pickerView(self, titleForRow: row, forComponent: component)
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerViewDelegate?.pickerViewSelected(row, item: items.object(at: row) as AnyObject)
    }
}
