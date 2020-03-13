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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorCell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        colorCell.layer.borderWidth = 1
        // Do any additional setup after loading the view.
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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
