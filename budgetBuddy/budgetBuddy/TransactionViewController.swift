//
//  SecondViewController.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/2/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController {

    @IBOutlet weak var transTable: UITableView!
    
    let globalData = DataManager.allData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transTable.delegate = self
        transTable.dataSource = self
        transTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // A bit annoying but probably necessary for deletion
        transTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newTrans" {
            segue.destination.preferredContentSize = CGSize(width: 350, height: 400)
            if let dest = segue.destination as? NewTransactionViewController {
                // Necessary protocol for handling new transaction additions
                dest.delegate = self
            }
            if let presentationController = segue.destination.popoverPresentationController { // 1
                presentationController.delegate = self // 2
            }
        }
        else if segue.identifier == "editTrans" {
            if let dest = segue.destination as? EditTransactionViewController {
                // Necessary protocol for handling new transaction additions
                dest.delegate = self
            }
        }
    }
    
    @IBAction func chooseTimeframe(_ sender: Any) {
        
    }
    
    
    // MARK: - Misc Helper Functions
    func stringifyDate(date: Date) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd-MMM-yyyy"
        
        return formatter.string(from: date)
    }

    func findColorForTrans(trans: Transaction) -> UIColor {
        let goals = globalData.goals
        print(trans.category)
        for goal in goals {
            if goal.category == trans.category {
                return goal.color!
            }
        }
        
        return .clear
    }

}


// MARK: - TableView Extension
extension TransactionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalData.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transaction") as! TransactionTableViewCell
        let trans = globalData.transactions[indexPath.row]
        cell.transaction = trans
        
        cell.category.text = trans.category
        cell.amount.text = "$\(trans.amount)"
        cell.location.text = trans.location ?? ""
        cell.date.text = stringifyDate(date: trans.date)
        cell.backgroundColor = findColorForTrans(trans: trans)
        let col = determineTextColor(bgColor: cell.backgroundColor ?? .white)
        cell.category.textColor = col
        cell.amount.textColor = col
        cell.location.textColor = col
        cell.date.textColor = col
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TransactionTableViewCell
        
        // Just to neaten up
        cell.setSelected(false, animated: true)
    }
    
}

// MARK: - Popover Delegate Extension
extension TransactionViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none // 3
    }
}

// MARK: - New Transaction Delegate
extension TransactionViewController: NewTransDelegate {
    
    func reloadTrans() {
        // TODO reload graph as well
        transTable.reloadData()
    }
}
