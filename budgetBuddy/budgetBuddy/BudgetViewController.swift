//
//  FirstViewController.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/2/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit
import CorePlot

class BudgetViewController: UIViewController {

    @IBOutlet weak var containingView: CPTGraphHostingView!
    @IBOutlet weak var budgetGoals: UITableView!
    
    let globalData = DataManager.allData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        budgetGoals.delegate = self
        budgetGoals.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        budgetGoals.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Specific details to get the popover to be the proper size
        if segue.identifier == "newGoal" {
            segue.destination.preferredContentSize = CGSize(width: 300, height: 200)
            if let dest = segue.destination as? NewBudgetGoalViewController {
                // Necessary protocol for handling new goal additions
                dest.delegate = self
            }
            if let presentationController = segue.destination.popoverPresentationController { // 1
                presentationController.delegate = self // 2
            }
        }
        
        else if segue.identifier == "showGoalDetail" {
            let dest = segue.destination as! GoalDetailViewController
            let cell = sender as! BudgetTableViewCell
            dest.goal = cell.goal!
            dest.delegate = self
        }
    }
    
    // MARK: - Graph Initialization
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      initPlot()
    }

    // Perform all initialization in a neat fashion
    func initPlot() {
      configureHostView()
      configureGraph()
      configureChart()
      configureLegend()
    }

    func configureHostView() {
        containingView.allowPinchScaling = false
    }

    func configureGraph() {
        // 1 - Create and configure the graph
        let graph = CPTXYGraph(frame: containingView.bounds)
        containingView.hostedGraph = graph
        graph.paddingLeft = 0.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0
        graph.paddingBottom = 0.0
        graph.axisSet = nil

        // 2 - Create text style
        let textStyle: CPTMutableTextStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor.black()
        textStyle.fontName = "HelveticaNeue-Bold"
        textStyle.fontSize = 16.0
        textStyle.textAlignment = .center

        /*
        // 3 - Set graph title and text style
        graph.title = "THIS WILL BE A TITLE IF NEEDED"
        graph.titleTextStyle = textStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchor.top
         */

    }

    func configureChart() {
        let graph = containingView.hostedGraph!

        // Create the chart itself
        let pieChart = CPTPieChart()
        pieChart.delegate = self
        pieChart.dataSource = self
        pieChart.pieRadius = (min(containingView.bounds.size.width, containingView.bounds.size.height) * 0.7) / 2
        pieChart.identifier = NSString(string: "Budget")
        pieChart.startAngle = CGFloat(Double.pi / 4)
        pieChart.sliceDirection = .clockwise
        pieChart.labelOffset = -0.6 * pieChart.pieRadius
        pieChart.pieInnerRadius = (min(containingView.bounds.size.width, containingView.bounds.size.height) * 0.7) / 4

        // Configure border style between slices
        let borderStyle = CPTMutableLineStyle()
        borderStyle.lineColor = CPTColor.white()
        borderStyle.lineWidth = 2.0
        pieChart.borderLineStyle = borderStyle

        // Configure text inside slices
        let textStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor.white()
        textStyle.textAlignment = .center
        pieChart.labelTextStyle = textStyle

        // Add chart to graph
        graph.add(pieChart)

    }

    func configureLegend() {
    }

    
}

// MARK: - Misc. Helper Functions

// Quick helper function for making text more visible
func determineTextColor(bgColor: UIColor) -> UIColor {
    let rgb = bgColor.cgColor.components!
    let luma = ((0.299 * rgb[0]) + (0.587 * rgb[1]) + (0.114 * rgb[2]))
    //let luma = 0.1
    if luma > 0.5 {
        return .black
    }
    else {
        return .white
    }
}


// MARK: - Popover Delegate Extension

extension BudgetViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none // 3
    }
}

// MARK: - Graph Extensions

extension BudgetViewController: CPTPieChartDelegate, CPTPieChartDataSource {
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        if globalData.goals.count < 2 { // Prevent an ugly glitchy graph
            return 0
        }
        return UInt(globalData.goals.count)
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        return globalData.goals[Int(idx)].amount
    }
    
    func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
        return CPTTextLayer(text: "\(globalData.goals[Int(idx)].category)")
    }
      
    func sliceFill(for pieChart: CPTPieChart, record idx: UInt) -> CPTFill? {
        return CPTFill(color: CPTColor(uiColor: globalData.goals[Int(idx)].color!))
    }
      
    func legendTitle(for pieChart: CPTPieChart, record idx: UInt) -> String? {
      return nil
    }
}

// MARK: - TableView Extensions

extension BudgetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalData.goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goal", for: indexPath) as! BudgetTableViewCell
        let goal = globalData.goals[indexPath.row]
        let tcol = determineTextColor(bgColor: goal.color!)
        
        cell.goal = goal
        cell.goalName.text = goal.category
        cell.goalName.textColor = tcol
        cell.amountLabel.text = "$\(goal.amount)"
        cell.amountLabel.textColor = tcol
        cell.backgroundColor = goal.color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! BudgetTableViewCell
        
        // Just to neaten up
        cell.setSelected(false, animated: true)
    }
    
    
}

// MARK: - New Goal Delegate Protocol
extension BudgetViewController: NewGoalDelegate {
    
    func reloadGoals() {
        // We need to reload basically the whole VC when goals are changed
        // TODO add donut chart reloading
        containingView.hostedGraph!.reloadData()
        budgetGoals.reloadData()
    }
}
