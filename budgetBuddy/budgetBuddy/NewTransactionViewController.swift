//
//  NewTransactionViewController.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/15/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit

class NewTransactionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var catPicker: UIPickerView!
    @IBOutlet weak var amt: UITextField!
    @IBOutlet weak var loc: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var bigName: UILabel!
    @IBOutlet weak var bgHighlight: UIView!
    
    let globalData = DataManager.allData
    var delegate: NewTransDelegate?
    var selectedCat: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        catPicker.dataSource = self
        catPicker.delegate = self
        datePicker.maximumDate = Date()
        amt.delegate = self
        loc.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Failsafe in case the goals are changed
        catPicker.reloadAllComponents()
        selectedCat = globalData.goals[0].category
        bigName.textColor = globalData.goals[0].color
        bgHighlight.backgroundColor = determineTextColor(bgColor: bigName.textColor)
    }
    
    @IBAction func submitTrans(_ sender: Any) {
        if let amt = amt.text {
            let num:Double? = Double(amt)
            if num != nil && num! > 0.0 {
                if let selected = selectedCat {
                    let trans = Transaction(amount: num!, category: selected, date: datePicker.date, location: loc.text)
                    
                    globalData.addTrans(trans: trans)
                    delegate?.reloadTrans()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    // MARK: - PickerView Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return globalData.goals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return globalData.goals[row].category
    }
    
    // A little stylistic fun with the colors
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if globalData.goals.count == 0 {
            return
        }
        bigName.textColor = globalData.goals[row].color
        selectedCat = globalData.goals[row].category
        bgHighlight.backgroundColor = determineTextColor(bgColor: bigName.textColor)
    }
}
