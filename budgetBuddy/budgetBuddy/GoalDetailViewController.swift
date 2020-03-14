//
//  GoalDetailViewController.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/13/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit

class GoalDetailViewController: UIViewController {

    @IBOutlet var containers: [UIView]!
    @IBOutlet weak var banner: UIView!
    @IBOutlet weak var goalNotes: UITextView!
    @IBOutlet weak var bigName: UILabel!
    @IBOutlet weak var totalGoal: UILabel!
    @IBOutlet weak var spentSoFar: UILabel!
    @IBOutlet weak var percentage: UILabel!
    
    var goal: Goal?
    var deleting = false
    var delegate: NewGoalDelegate?
    
    let globalData = DataManager.allData
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for container in containers {
            container.layer.borderWidth = 1
            container.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        }
        bigName.text = goal!.category
        banner.backgroundColor = goal!.color
        totalGoal.text = "\(goal!.amount)"
        // TODO spentsoFar
        // TODO Percentage
        
        goalNotes.delegate = self
        goalNotes.text = goal!.notes ?? "Tap here to add notes to this goal"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if deleting {
            return
        }
        globalData.updateGoal(category: goal!.category, goal: goal!)
    }
    
    @IBAction func deleteGoal(_ sender: Any) {
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
