//
//  FilterViewController.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/16/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var datePicker: UIPickerView!
    
    let formatter = DateFormatter()
    let totalYearNum = 40
    var delegate: NewTransDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.delegate = self
        datePicker.dataSource = self
        datePicker.reloadAllComponents()
    }
    
    @IBAction func selectTimeframe(_ sender: Any) {
        let cal = Calendar.current
        let offset = cal.component(.year, from: Date())
        
        let month = datePicker.selectedRow(inComponent: 0)
        let year = offset - datePicker.selectedRow(inComponent: 1)
        delegate?.filterTrans(year: year, month: month)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - PickerView Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            // Month first
            return 12
        }
        else {
            // For now lets do 40 years TODO
            return totalYearNum
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return formatter.shortMonthSymbols[row]
        }
        else {
            let currentYear = Calendar.current.component(.year, from: Date())
            return String(currentYear - row)
        }
    }
}
