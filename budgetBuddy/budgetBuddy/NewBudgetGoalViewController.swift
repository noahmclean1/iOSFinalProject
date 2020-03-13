//
//  NewBudgetGoalViewController.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/12/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit

class NewBudgetGoalViewController: UIViewController {

    @IBOutlet weak var colorCell: UIButton!
    @IBOutlet weak var categoryName: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    let globalData = DataManager.allData
    weak var delegate: NewGoalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorCell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        colorCell.layer.borderWidth = 1
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Reset on reappearing!
        categoryName.text = nil
        amount.text = nil
        colorCell.backgroundColor = .clear
        warningLabel.text = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "colorPick" {
            segue.destination.preferredContentSize = CGSize(width: 300, height: 450)
            if let dest = segue.destination as? ColorSelectorViewController {
                dest.delegate = self
            }
            if let presentationController = segue.destination.popoverPresentationController { // 1
                presentationController.delegate = self // 2
            }
        }
    }
    
    //
    @IBAction func submitNewGoal(_ sender: Any) {
        let category = categoryName.text
        let amountString = amount.text
        
        if category != nil || amountString != nil {
            let amt:Double? = Double(amountString!)
            if let amt = amt {
                if colorCell.backgroundColor == .clear {
                    warningLabel.text = "Choose a color"
                    return
                }
                let newGoal = Goal(category: category!, amount: amt, color: colorCell.backgroundColor!)
                globalData.addGoal(goal: newGoal) //TODO
                delegate?.reloadGoals()
                self.dismiss(animated: true, completion: nil)
                return
            }
        }
        warningLabel.text = "Invalid values"
    }

}

// MARK: - Popover Extension
extension NewBudgetGoalViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none // 3
    }
}

// MARK: - Color Picker Protocol
extension NewBudgetGoalViewController: ColorProtocol {
    
    func setColor(color: UIColor) {
        colorCell.backgroundColor = color
    }
}
