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
    var category: String
    var amount: Double
    let color: UIColor?
    var notes: String?
    var spentSoFar: Double
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
    
    var totalBudget:Double = 0.0
    var goals = [Goal]()
    var transactions = [Transaction]()
    
    func addGoal(goal: Goal) -> Bool {
        for existingGoal in goals {
            if existingGoal.category == goal.category {
                return false
            }
        }
        goals.append(goal)
        totalBudget += goal.amount
        return true
    }
    
    func updateGoal(category: String, goal: Goal) {
        for var oldGoal in goals {
            if oldGoal.category == category {
                totalBudget -= oldGoal.amount
                totalBudget += goal.amount
                oldGoal.amount = goal.amount
                oldGoal.notes = goal.notes
                
                if oldGoal.category != goal.category {
                    // Change any relevant transactions TODO
                    
                    oldGoal.category = goal.category
                }
                
                
                break
            }
        }
    }
    
    func deleteGoal(category: String) {
        for goal in goals {
            // Do specific work to account for removal
            if goal.category == category {
                totalBudget -= goal.amount
                // Remove transactions TODO
            }
        }
        // Actually delete the goal
        goals = goals.filter { $0.category != category}
    }
}
