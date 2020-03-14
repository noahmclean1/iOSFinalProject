//
//  GoalDetailViewController.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/13/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit

let defaultNote = "Tap here to add notes to this goal"

class GoalDetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var containers: [UIView]!
    @IBOutlet weak var banner: UIView!
    @IBOutlet weak var goalNotes: UITextView!
    @IBOutlet weak var bigName: UILabel!
    @IBOutlet weak var totalGoal: UILabel!
    @IBOutlet weak var spentSoFar: UILabel!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var editTotalGoal: UITextField!
    
    var goal: Goal?
    var deleting = false
    var delegate: NewGoalDelegate?
    
    let globalData = DataManager.allData
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize visuals & values
        for container in containers {
            container.layer.borderWidth = 1
            container.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        }
        bigName.text = goal!.category
        banner.backgroundColor = goal!.color
        updatePageValues()
        
        if goal!.spentSoFar > goal!.amount {
            spentSoFar.textColor = .red
        }
        else {
            spentSoFar.textColor = .black
        }
        
        // Allow for stealthy editing for amounts
        editTotalGoal.text = "\(goal!.amount)"
        editTotalGoal.delegate = self
        totalGoal.isUserInteractionEnabled = true
        let aSelector : Selector = Selector(("tapTotalGoal"))
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        totalGoal.addGestureRecognizer(tapGesture)
        
        // Initialize textview for notes
        goalNotes.delegate = self
        goalNotes.text = goal!.notes ?? defaultNote
        deleting = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Don't bother to update if we're deleting the goal
        if deleting {
            return
        }
        
        // Update notes if needed
        if goalNotes.text != defaultNote {
            goal!.notes = goalNotes.text
        }
        
        globalData.updateGoal(category: goal!.category, goal: goal!)
        delegate?.reloadGoals()
    }
    
    // Callable helper for when we change relevant values
    func updatePageValues() {
        totalGoal.text = "\(goal!.amount)"
        spentSoFar.text = "\(goal!.spentSoFar)"
        percentage.text = "\(goal!.spentSoFar/goal!.amount)"
        editTotalGoal.isHidden = true
    }
    
    @objc func tapTotalGoal() {
        totalGoal.isHidden = true
        editTotalGoal.isHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editTotalGoal.isHidden = true
        totalGoal.isHidden = false
        if let txt = editTotalGoal.text {
            let amt:Double? = Double(txt)
            if let amt = amt {
                if amt > 0.0 {
                    goal!.amount = amt
                    updatePageValues()
                    textField.resignFirstResponder()
                }
            }
        }
        return true
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        
        let alert = UIAlertController(title: goal!.category, message: "Are you sure you want to delete this goal & category? This will also delete all related transactions", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: deleteCurrentGoal))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteCurrentGoal(_ alert: UIAlertAction) {
        globalData.deleteGoal(category: goal!.category)
        deleting = true
        delegate?.reloadGoals()
        self.dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - Text View Delegate Extension
extension GoalDetailViewController: UITextViewDelegate {
    
    // Save the notes to this goal on editing
    func textViewDidEndEditing(_ textView: UITextView) {
        goal!.notes = textView.text
    }
}
