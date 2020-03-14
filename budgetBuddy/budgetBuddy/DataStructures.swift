//
//  DataStructures.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/12/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import Foundation
import UIKit

struct Goal {
    let category: String
    let amount: Double
    let color: UIColor?
    var notes: String?
}

struct Transaction {
    let amount: Double
    let category: String
    let date: Date
    let location: String?
}

// This will be where we keep our user Transaction & Budget Goal data
public class DataManager {
    
    // We're sharing this data across all VCs
    public static let allData = DataManager()
    
    var goals = [Goal]()
    var transactions = [Transaction]()
    
    func addGoal(goal: Goal) {
        goals.append(goal)
    }
    
    func updateGoal(category: String, goal: Goal) {
        
    }
    
    func deleteGoal(category: String) {
        goals = goals.filter { $0.category != category}
    }
}
