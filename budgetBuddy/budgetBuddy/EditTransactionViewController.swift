//
//  EditTransactionViewController.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/15/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit

class EditTransactionViewController: UIViewController, UITextFieldDelegate {

    var trans: Transaction?
    var col: UIColor?
    let globalData = DataManager.allData
    var newT: Transaction?
    
    @IBOutlet var sideViews: [UIView]!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var catField: UITextField!
    @IBOutlet weak var locField: UITextField!
    @IBOutlet weak var amtField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    var delegate: NewTransDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up side colors
        for view in sideViews {
            view.backgroundColor = col
        }
        
        // Set up labels
        categoryLabel.text = trans!.category
        amountLabel.text = "$\(trans!.amount)"
        if trans?.location == nil || trans!.location! == "" {
            locationLabel.text = "No location"
        }
        else {
            locationLabel.text = trans!.location
        }
        
        // Allow for stealthy editing for each value
        catField.text = categoryLabel.text
        catField.delegate = self
        categoryLabel.isUserInteractionEnabled = true
        let aSelector : Selector = Selector(("tapCategory"))
        let catTapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        catTapGesture.numberOfTapsRequired = 1
        categoryLabel.addGestureRecognizer(catTapGesture)
        
        locField.text = trans!.location ?? ""
        locField.delegate = self
        locationLabel.isUserInteractionEnabled = true
        let bSelector : Selector = Selector(("tapLocation"))
        let locTapGesture = UITapGestureRecognizer(target: self, action: bSelector)
        locTapGesture.numberOfTapsRequired = 1
        locationLabel.addGestureRecognizer(locTapGesture)
        
        amtField.text = "\(trans!.amount)"
        amtField.delegate = self
        amountLabel.isUserInteractionEnabled = true
        let cSelector : Selector = Selector(("tapAmount"))
        let amtTapGesture = UITapGestureRecognizer(target: self, action: cSelector)
        amtTapGesture.numberOfTapsRequired = 1
        amountLabel.addGestureRecognizer(amtTapGesture)
        
        // Create a copy to record changes
        newT = Transaction(amount: trans!.amount, category: trans!.category, date: trans!.date, location: trans!.location)
    }

    // MARK: - VC Interaction Functions
    @objc func tapCategory() {
        warningLabel.text = ""
        catField.isHidden = false
        categoryLabel.isHidden = true
    }
    
    @objc func tapLocation() {
        warningLabel.text = ""
        locField.isHidden = false
        locationLabel.isHidden = true
    }
    
    @objc func tapAmount() {
        warningLabel.text = ""
        amtField.isHidden = false
        amountLabel.isHidden = true
    }
    
    @IBAction func submitChanges(_ sender: Any) {
        if trans != newT {
            globalData.replaceTransaction(oldTrans: trans!, newTrans: newT!)
            delegate?.reloadTrans()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - TextField Interactions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == catField {
            catField.isHidden = true
            categoryLabel.isHidden = false
            if let txt = catField.text {
                var exists = false
                var color = UIColor.clear
                for goal in globalData.goals {
                    if goal.category == txt {
                        exists = true
                        color = goal.color!
                        break
                    }
                }
                
                if !exists {
                    warningLabel.text = "No category with that name exists"
                }
                else {
                    newT!.category = txt
                    categoryLabel.text = txt
                    warningLabel.text = ""
                    
                    for view in sideViews {
                        view.backgroundColor = color
                    }
                }
                
                
            }
        }
        else if textField == locField {
            locField.isHidden = true
            locationLabel.isHidden = false
            if let txt = locField.text {
                newT!.location = txt
                locationLabel.text = txt
                warningLabel.text = ""
            }
        }
        else if textField == amtField {
            amtField.isHidden = true
            amountLabel.isHidden = false
            if let txt = amtField.text {
                let amt:Double? = Double(txt)
                if let amt = amt {
                    if amt > 0.0 {
                        newT!.amount = amt
                        amountLabel.text = "$\(amt)"
                        warningLabel.text = ""
                    }
                }
                else {
                    warningLabel.text = "Invalid Amount"
                }
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
}
