//
//  TrendViewController.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/2/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit
import CorePlot

class TrendViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CPTAxisDelegate {

    @IBOutlet weak var bigTitle: UILabel!
    @IBOutlet weak var catPicker: UIPickerView!
    @IBOutlet var colorViews: [UIView]!
    @IBOutlet var containerViews: [UIView]!

    @IBOutlet weak var dailySpending: UILabel!
    @IBOutlet weak var transSize: UILabel!
    @IBOutlet weak var ranking: UILabel!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var expensiveLoc: UILabel!
    @IBOutlet weak var dueToGoOver: UILabel!
    
    var category: Goal?
    let globalData = DataManager.allData
    var timeStamp: String?
    let formatter = DateFormatter()
    var transactionsCurrent = [Transaction]()
    var totalTransactions = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Exemption for empty goals
        if globalData.goals.count == 0 {
            return
        }
        
        category = globalData.goals[0]
        
        catPicker.delegate = self
        catPicker.dataSource = self
        catPicker.reloadAllComponents()
        
        // Make the boxes pretty
        for view in containerViews {
            view.layer.borderColor = CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1)
            view.layer.borderWidth = 1
        }
        
        formatter.dateFormat = "yyyy MMM"
        timeStamp = formatter.string(from: Date())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadPage()
    }
    
    func reloadPage() {
        // Grab relevant data
        let cat = category!.category
        let transactions = globalData.transactions[timeStamp!]!
        transactionsCurrent = transactions.filter { $0.category == cat }
        totalTransactions = globalData.getOrderedTransactionsForCategory(category: cat)
        
        // Style
        for view in colorViews {
            view.backgroundColor = category!.color
        }
        
        // Content
        
        bigTitle.text = "Statistics about \(cat) Budget"
        dailySpending.text = "$" + String(format: "%.2f", calcDailySpending())
        transSize.text = "$" + String(format: "%.2f", averageTransaction())
        ranking.text = "\(catRanking(category: category!))"
        percentage.text = String(format: "%.2f", budgetPercent(category: category!)) + "%"
        expensiveLoc.text = "\(highestLoc(category: cat) ?? "None")"
        dueToGoOver.text = goingOver()
        
    }
    
    // MARK: - Calculation Functions
    
    func calcDailySpending() -> Double {
        let cal = Calendar.current
        let day = cal.component(.day, from: Date())
        
        var sum = 0.0
        for t in transactionsCurrent {
            sum += t.amount
        }
        
        return (sum/Double(day))
    }
    
    func averageTransaction() -> Double {
        var sum = 0.0
        var total = 0
        for t in transactionsCurrent {
            sum += t.amount
            total += 1
        }
        return (sum/Double(total))
    }
    
    func catRanking(category: Goal) -> Int {
        let amt = category.amount
        var rank = 1
        for g in globalData.goals {
            if g.amount >= amt && g.category != category.category {
                rank += 1
            }
        }
        return rank
    }
    
    func budgetPercent(category: Goal) -> Double {
        var sum = 0.0
        for g in globalData.goals {
            sum += g.amount
        }
        
        return (category.amount/sum * 100.0)
    }
    
    func highestLoc(category: String) -> String? {
        var counter = [String: Int]()
        for t in transactionsCurrent {
            if let soFar = counter[t.location ?? ""] {
                counter[t.location ?? ""] = soFar + 1
            }
        }
        
        var mloc = ""
        var num = 0
        for (loc, val) in counter {
            if val > num {
                mloc = loc
                num = val
            }
        }
        
        if mloc == "" {
            return nil
        }
        else {
            return mloc
        }
    }
    
    func goingOver() -> String {
        let cal = Calendar.current
        let day = cal.component(.day, from: Date())
        let range = cal.range(of: .day, in: .month, for: Date())
        let daily = category!.spentSoFar / Double(day)
        let projected = daily * Double(range!.count)
        
        if projected > category!.amount {
            dueToGoOver.textColor = .red
            return "Spending Above Your Goal"
        }
        else if projected == category!.amount {
            dueToGoOver.textColor = .black
            return "Spending Exactly Your Goal!"
        }
        else {
            dueToGoOver.textColor = .green
            return "Spending Under Your Goal"
        }
    }
    
    // MARK: - PickerView Delegate Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return globalData.goals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return globalData.goals[row].category
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let goal = globalData.goals[row]
        
        category = goal
        reloadPage()
    }
}

