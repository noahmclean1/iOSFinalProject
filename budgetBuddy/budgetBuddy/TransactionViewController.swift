//
//  SecondViewController.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/2/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit
import CorePlot

class TransactionViewController: UIViewController {

    @IBOutlet weak var transTable: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hostView: CPTGraphHostingView!
    
    let globalData = DataManager.allData
    let formatter = DateFormatter()
    let dayFormatter = DateFormatter()
    var setDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "yyyy MMM"
        dayFormatter.dateFormat = "dd-MMM-yyy"
        setDate = formatter.string(from: Date())
        dateLabel.text = setDate
        
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
                let cell = sender as! TransactionTableViewCell
                
                dest.trans = cell.transaction
                dest.col = findColorForTrans(trans: cell.transaction!)
                dest.delegate = self
            }
        }
        else if segue.identifier == "filterPop" {
            segue.destination.preferredContentSize = CGSize(width: 250, height: 300)
            if let dest = segue.destination as? FilterViewController {
                dest.delegate = self
            }
            if let presentationController = segue.destination.popoverPresentationController { // 1
                presentationController.delegate = self // 2
            }
        }
    }
    
    // MARK: - Bar Plot Initialization
    let BarInitialX = 0.25
    
    func maximumTransaction() -> Double {
        var biggest = 0.0
        guard let ts = globalData.transactions[setDate!] else {
            return 0.0
        }
        for t in ts {
            biggest = max(t.amount, biggest)
        }
        return biggest
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      initPlot()
    }

    func initPlot() {
      configureHostView()
      configureGraph()
      configureChart()
      configureAxes()
    }

    func configureHostView() {
        hostView.allowPinchScaling = false
    }

    func configureGraph() {
        guard let ts = globalData.transactions[setDate!] else {
            return
        }
        
        // Initialize Graph Object
        let graph = CPTXYGraph(frame: hostView.bounds)
        graph.plotAreaFrame?.masksToBorder = false
        hostView.hostedGraph = graph

        // Basic visual settings
        graph.apply(CPTTheme(named: CPTThemeName.plainWhiteTheme))
        graph.fill = CPTFill(color: CPTColor.clear())
        graph.paddingBottom = 30.0
        graph.paddingLeft = 30.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0

        // Determine plot dimensions
        let xMin = 0.0
        let xMax = Double(ts.count)
        let yMin = 0.0
        let yMax = 1.4 * maximumTransaction() // A little extra space on top for comfort
        
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin))
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMin), lengthDecimal: CPTDecimalFromDouble(yMax - yMin))
    }

    func configureChart() {
        
        let plot = CPTBarPlot()
        plot.fill = .none
        
        // Set up line style
        let barLineStyle = CPTMutableLineStyle()
        barLineStyle.lineColor = CPTColor.lightGray()
        barLineStyle.lineWidth = 0.5

        // Add plots to graph
        let BarWidth = 0.25 //The bar width will automatically adapt
        guard let graph = hostView.hostedGraph else { return }
        plot.dataSource = self
        plot.delegate = self
        plot.barWidth = NSNumber(value: BarWidth)
        plot.barOffset = NSNumber(value: BarInitialX)
        plot.lineStyle = barLineStyle
        graph.add(plot, to: graph.defaultPlotSpace)
        
    }

    func configureAxes() {
        let axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineWidth = 2.0
        axisLineStyle.lineColor = CPTColor.black()
        
        guard let axisSet = hostView.hostedGraph?.axisSet as? CPTXYAxisSet else { return }
        
        // Configure the x-axis
        if let xAxis = axisSet.xAxis {
          xAxis.labelingPolicy = .none
          xAxis.majorIntervalLength = 1
          xAxis.axisLineStyle = axisLineStyle
          var majorTickLocations = Set<NSNumber>()
          var axisLabels = Set<CPTAxisLabel>()
            for (idx, t) in globalData.transactions[setDate!]!.enumerated() {
            majorTickLocations.insert(NSNumber(value: idx))
                let label = CPTAxisLabel(text: dayFormatter.string(from: t.date), textStyle: CPTTextStyle())
            label.tickLocation = NSNumber(value: idx)
            label.offset = 5.0
            label.alignment = .left
            axisLabels.insert(label)
          }
          xAxis.majorTickLocations = majorTickLocations
          xAxis.axisLabels = axisLabels
        }
        
        // Configure the y-axis
        if let yAxis = axisSet.yAxis {
            yAxis.labelingPolicy = .automatic
            yAxis.labelOffset = -10.0
            yAxis.minorTicksPerInterval = 3
            yAxis.majorTickLength = 30
            let majorTickLineStyle = CPTMutableLineStyle()
            majorTickLineStyle.lineColor = CPTColor.black().withAlphaComponent(0.1)
            yAxis.majorTickLineStyle = majorTickLineStyle
            yAxis.minorTickLength = 20
            let minorTickLineStyle = CPTMutableLineStyle()
            minorTickLineStyle.lineColor = CPTColor.black().withAlphaComponent(0.05)
            yAxis.minorTickLineStyle = minorTickLineStyle
            yAxis.axisLineStyle = axisLineStyle
        }
    }
    
    // MARK: - Misc Helper Functions
    func stringifyDate(date: Date) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd-MMM-yyyy"
        
        return formatter.string(from: date)
    }

    func findColorForTrans(trans: Transaction) -> UIColor {
        let goals = globalData.goals
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
        if let t = globalData.transactions[setDate!] {
            return t.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transaction") as! TransactionTableViewCell
        let trans = globalData.transactions[setDate!]![indexPath.row]
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
    
    // Add swipe deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let trans = globalData.transactions[setDate!]![indexPath.row]
            globalData.removeTrans(trans: trans)
            reloadTrans()
        }
    }
    
}

// MARK: - Popover Delegate Extension
extension TransactionViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - Bar Plot Extension
extension TransactionViewController: CPTBarPlotDataSource, CPTBarPlotDelegate {
  
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        guard let ts = globalData.transactions[setDate!] else {
            return 0
        }
    return UInt(ts.count)
    }

    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        if fieldEnum == UInt(CPTBarPlotField.barTip.rawValue) {
            guard let ts = globalData.transactions[setDate!] else {
                return 0
            }
            return ts[Int(idx)].amount
        }
    return idx
    }

    // Bind each bar to a category color
    func barFill(for barPlot: CPTBarPlot, record idx: UInt) -> CPTFill? {
        guard let ts = globalData.transactions[setDate!] else {
            return .none
        }

        return CPTFill(color: CPTColor(uiColor: findColorForTrans(trans: ts[Int(idx)])))
    }
    
    func barPlot(_ plot: CPTBarPlot, barWasSelectedAtRecord idx: UInt, with event: UIEvent) {
        performSegue(withIdentifier: "editTrans", sender: transTable.cellForRow(at: IndexPath(row: Int(idx), section: 0)))
    }
}

// MARK: - New Transaction Delegate
extension TransactionViewController: NewTransDelegate {
    
    func reloadTrans() {
        
        initPlot()
        //hostView.hostedGraph!.reloadData()
        transTable.reloadData()
        dateLabel.text = setDate
    }
    
    func filterTrans(year: Int, month: Int) {
        var dc = DateComponents()
        var realMonth = month
        dc.year = year
        if month == 11 {
            realMonth = 0
        }
        dc.month = realMonth + 1
        dc.day = 1
        let cal = Calendar.current
                
        setDate = formatter.string(from: cal.date(from: dc)!)
        
        reloadTrans()
    }
       
}

