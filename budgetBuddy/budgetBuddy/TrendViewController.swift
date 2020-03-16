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
    @IBOutlet weak var graphHost: CPTGraphHostingView!
    
    var category: Goal?
    let globalData = DataManager.allData
    let burnGraph = CPTXYGraph(frame: .zero)
    
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
        
        bigTitle.text = "Statistics about \(category!.category) Budget"
        
        let ts = globalData.getOrderedTransactionsForCategory(category: category!.category)
        
        initPlot(transactions: ts)
    }
    
    func reloadPage() {
        let transactions = globalData.getOrderedTransactionsForCategory(category: category!.category)
        
        // TODO reset any statistics labels
        
        initPlot(transactions: transactions)
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
    
    // MARK: - Graph Initialization
    func initPlot(transactions: [Transaction]) {
        configureHostView()
        configureGraph()
        configureChart()
        configureAxes()
    }
    
    func configureHostView() {
        graphHost.allowPinchScaling = false
    }
    
    func configureGraph() {
        // Create graph from theme
        burnGraph.apply(CPTTheme(named: .darkGradientTheme))

        let hostingView = graphHost as! CPTGraphHostingView
        hostingView.hostedGraph = burnGraph

        // Paddings
        burnGraph.paddingLeft   = 10.0
        burnGraph.paddingRight  = 10.0
        burnGraph.paddingTop    = 10.0
        burnGraph.paddingBottom = 10.0
    }
    
    func configureChart() {
        // Plot space
        let plotSpace = burnGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.yRange = CPTPlotRange(location:1.0, length:2.0)
        plotSpace.xRange = CPTPlotRange(location:1.0, length:3.0)

    }
    
    func configureAxes() {
        // Axes
        let axisSet = burnGraph.axisSet as! CPTXYAxisSet

        if let x = axisSet.xAxis {
            x.majorIntervalLength   = 0.5
            x.orthogonalPosition    = 2.0
            x.minorTicksPerInterval = 2
            x.labelExclusionRanges  = [
                CPTPlotRange(location: 0.99, length: 0.02),
                CPTPlotRange(location: 1.99, length: 0.02),
                CPTPlotRange(location: 2.99, length: 0.02)
            ]
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 0.5
            y.minorTicksPerInterval = 5
            y.orthogonalPosition    = 2.0
            y.labelExclusionRanges  = [
                CPTPlotRange(location: 0.99, length: 0.02),
                CPTPlotRange(location: 1.99, length: 0.02),
                CPTPlotRange(location: 3.99, length: 0.02)
            ]
            y.delegate = self
        }
    }

}

extension TrendViewController: CPTScatterPlotDataSource {
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(0)
    }
    
}
