//
//  DataStructures.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/12/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

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

class Transaction: Equatable {
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return (
            lhs.amount == rhs.amount &&
                lhs.category == rhs.category &&
                lhs.date == rhs.date &&
                lhs.location == rhs.location
        )
    }
    
    var amount: Double
    var category: String
    let date: Date
    var location: String?
    
    init(amount: Double, category: String, date: Date, location: String?) {
        self.amount = amount
        self.category = category
        self.date = date
        self.location = location
    }
}

// MARK: - Extra Helper Functions

// Turns UIColors to strings for easy storage
func colorToString(color: UIColor) -> String {
    guard let rgb = color.cgColor.components, rgb.count >= 3 else {
        return ""
    }
    
    let r = Float(rgb[0])
    let g = Float(rgb[1])
    let b = Float(rgb[2])
    
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
    
    return UIColor(cgColor: CGColor(srgbRed: CGFloat(rval)/255.0, green: CGFloat(gval)/255.0, blue: CGFloat(bval)/255.0, alpha: 1.0))
}

// MARK: - Global Data Manager
// This is where we keep our user Transaction & Budget Goal data
public class DataManager {
    
    // We're sharing this data across all VCs
    public static let allData = DataManager()
    
    var curStamp: String?
    var totalBudget:Double = 0.0
    var goals = [Goal]()
    var transactions = [String : [Transaction]]()
    
    func getOrderedTransactionsForCategory(category: String) -> [Transaction] {
        let formatter = DateFormatter()
        let sms = formatter.shortMonthSymbols
        var keys = Array(transactions.keys)
        var ts = [Transaction]()
        keys.sort {
            // Sort 2 datestamps in order of oldest-first
            let lhs = ($0.prefix(4), $0.suffix(3))
            let rhs = ($1.prefix(4), $1.suffix(3))
            
            if lhs.0 < rhs.0 { // Ex: 2008 vs 2020
                return true
            }
            else if lhs.0 == rhs.0 {
                let lmonth = sms!.firstIndex(of: String(lhs.1))!
                let rmonth = sms!.firstIndex(of: String(rhs.1))!
                
                return lmonth < rmonth // Ex: 2020 Jan vs 2020 Feb -> true
            }
            else { // Ex: 2020 vs 2019
                return false
            }
        }
        
        // Now traverse in-order
        for key in keys {
            let keyTrans = transactions[key]!
            for t in keyTrans {
                if t.category == category {
                    ts.append(t)
                }
            }
        }
        
        return ts
    }
    
    // MARK: - Load & Store
    func saveData() {
        let defaults = UserDefaults.standard
        
        var savingList = [[String : Any]]()
        var tList = [[String : Any]]()
        
        for goal in goals {
           let goalFormat = [
            "category" : goal.category,
            "amount" : goal.amount,
            "notes" : goal.notes ?? "",
            "color" : colorToString(color: goal.color!)
            ] as [String : Any]
            savingList.append(goalFormat)
        }
        
        defaults.set(savingList, forKey: "goals")
        
        for (_, transList) in transactions {
            for t in transList {
                let tdict = [
                    "amount": t.amount,
                    "category": t.category,
                    "date": t.date,
                    "location": t.location ?? ""
                    ] as [String : Any]
                tList.append(tdict)
            }
        }
        
        defaults.set(tList, forKey: "transactions")
    }
    
    func loadData() {
        let defaults = UserDefaults.standard
        
        let count = defaults.integer(forKey: "launch")
        
        if count < 2 {
            defaults.set(count + 1, forKey: "launch")
        }
        else if count == 2 {
            SKStoreReviewController.requestReview()
        }
        
        var goalArray = defaults.array(forKey: "goals") as? [[String : Any]]
        var tArray = defaults.array(forKey: "transactions") as? [[String : Any]]
        
        if goalArray == nil {
            goalArray = [[String : Any]]()
        }
        if tArray == nil {
            tArray = [[String : Any]]()
        }
        
        // Set the spending so far to be 0 and add in transactions later
        for goal in goalArray! {
            let newGoal = Goal(category: goal["category"] as! String, amount: goal["amount"] as! Double, color: htmlToColor(color: goal["color"] as! String), spentSoFar: 0.0)
            if goal["notes"] as! String != "" {
                newGoal.notes = goal["notes"] as? String
            }
            
            // We can safely ignore the validity since we know this will always be true
            _ = DataManager.allData.addGoal(goal: newGoal)
        }
                
        // Add each transaction using our standard method
        for trans in tArray! {
            let newT = Transaction(amount: trans["amount"] as! Double, category: trans["category"] as! String, date: trans["date"] as! Date, location: trans["location"] as? String)
            
            DataManager.allData.addTrans(trans: newT)
        }
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
            if oldGoal.category == goal.category {
                totalBudget -= oldGoal.amount
                totalBudget += goal.amount
                oldGoal.amount = goal.amount
                oldGoal.notes = goal.notes
                
                if oldGoal.category != category {
                    // Change any relevant transactions TODO
                    for (_, tList) in transactions {
                        for t in tList {
                            if t.category == category {
                                t.category = goal.category
                            }
                        }
                    }
                    
                    
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
                
                for (_, var tList) in transactions {
                    tList = tList.filter { $0.category != category }
                }
                
                //transactions = transactions.filter { $0.category != category }
                
                break
            }
        }
        // Actually delete the goal
        goals = goals.filter { $0.category != category}
    }
    
    // MARK: - Transaction Modification
    
    func addTrans(trans: Transaction) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM"
        let dateStamp = formatter.string(from: trans.date)
        var ind = 0
        
        // Update goal information
        for goal in goals {
            if goal.category == trans.category {
                
                if formatter.string(from: trans.date) == curStamp! {
                    goal.spentSoFar += trans.amount
                }
                
                break
            }
        }
        
        // Insert transaction into proper bucket-list
        if let tList = transactions[dateStamp] {
            var placed = false
            for (index,t) in tList.enumerated() {
                if t.date >= trans.date {
                    ind = index
                    placed = true
                    break
                }
            }
            
            if !placed {
                ind = tList.count
            }
            
        }
        else {
            transactions[dateStamp] = [trans]
            return
        }
        
        transactions[dateStamp]!.insert(trans, at: ind)
    }
    
    func removeTrans(trans: Transaction) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM"
        
        for goal in goals {
            // Alter any tied-up data
            if goal.category == trans.category {
                
                if formatter.string(from: trans.date) == curStamp! {
                    goal.spentSoFar -= trans.amount
                }
                
                break
            }
        }
        
        // Fully remove the transaction by finding it first
        let dateStamp = formatter.string(from: trans.date)
        
        guard let tList = transactions[dateStamp] else {
            print("Error: removing transaction month not found")
            return
        }
        
        guard let ind = tList.firstIndex(of: trans) else {
            print("Error: removing transaction not in list")
            return
        }
        
        transactions[dateStamp]!.remove(at: ind)
    }
    
    func replaceTransaction(oldTrans: Transaction, newTrans: Transaction) {
        removeTrans(trans: oldTrans)
        addTrans(trans: newTrans)
    }
}
