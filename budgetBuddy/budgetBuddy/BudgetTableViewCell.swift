//
//  BudgetTableViewCell.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/13/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit

class BudgetTableViewCell: UITableViewCell {

    @IBOutlet weak var goalName: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var goal: Goal?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
