//
//  DataStructures.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/12/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Important Data Structures
class Goal {
    var category: String
    var amount: Double
    let color: UIColor?
    var notes: String?
    var spentSoFar: Double
    
    init(category: String, amount: Double, color: UIColor?, spentSoFar: Double) {
        self.category = category
        self.amount = amount
        self.color = color
        self.spentSoFar = spentSoFar
    }
}

class Transaction {
    var amount: Double
    var category: String
    let date: Date
    let location: String?
    
    init(amount: Double, category: String, date: Date, location: String?) {
        self.amount = amount
        self.category = category
        self.date = date
        self.location = location
    }
}

// MARK: - Extra Helper Functions

func colorToString(color: UIColor) -> String {
    guard let rgb = color.cgColor.components, rgb.count >= 3 else {
        return ""
    }
    
    let r = Float(rgb[0])
    let g = Float(rgb[1])
    let b = Float(rgb[2])
    
    print("COLOR")
    print(r)
    print(g)
    print(b)
    
    return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
}

// Helper to easily turn a 6-digit color hex to UIColor
func htmlToColor(color: String) -> UIColor {
    let red = String(color.prefix(2))
    let green = String(color.prefix(4).suffix(2))
    let blue = String(color.suffix(2))
    
    var rval:UInt64 = 0
    var gval:UInt64 = 0
    var bval:UInt64 = 0
    Scanner(string: red).scanHexInt64(&rval)
    Scanner(string: green).scanHexInt64(&gval)
    Scanner(string: blue).scanHexInt64(&bval)
    
    print("HTML")
    print(rval)
    print(gval)
    print(bval)
    
    return UIColor(cgColor: CGColor(srgbRed: CGFloat(rval)/255.0, green: CGFloat(gval)/255.0, blue: CGFloat(bval)/255.0, alpha: 1.0))
}

// MARK: - Global Data Manager
// This will be where we keep our user Transaction & Budget Goal data
public class DataManager {
    
    // We're sharing this data across all VCs
    public static let allData = DataManager()
    
    var totalBudget:Double = 0.0
    var goals = [Goal]()
    var transactions = [Transaction]()
    
    // MARK: - Load & Store
    func saveData() {
        let defaults = UserDefaults.standard
        
        var savingList = [[String : Any]]()
        
        for goal in goals {
           let goalFormat = [
            "category" : goal.category,
            "amount" : goal.amount,
            "notes" : goal.notes ?? "",
            "color" : colorToString(color: goal.color!),
            "spentSoFar" : goal.spentSoFar
            ] as [String : Any]
            savingList.append(goalFormat)
        }
        
        print(savingList)
        defaults.set(savingList, forKey: "goals")
        
        // TODO save Transactions
    }
    
    func loadData() {
        let defaults = UserDefaults.standard
        
        let goalArray = defaults.array(forKey: "goals") as! [[String : Any]]
        for goal in goalArray {
            let newGoal = Goal(category: goal["category"] as! String, amount: goal["amount"] as! Double, color: htmlToColor(color: goal["color"] as! String), spentSoFar: goal["spentSoFar"] as! Double)
            
            // We can safely ignore the validity since we know this will always be true
            _ = DataManager.allData.addGoal(goal: newGoal)
        }
        
        print(goals[0].color!)
        // TODO load Transactions
    }
    
    // MARK: - Goal Modification
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
        for oldGoal in goals {
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
    
    // MARK: - Transaction Modification
}
