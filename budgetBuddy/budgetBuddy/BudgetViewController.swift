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
    
    let goals = DataManager.allData.goals
    
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
            if let presentationController = segue.destination.popoverPresentationController { // 1
                presentationController.delegate = self // 2
            }
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

        // 3 - Set graph title and text style
        graph.title = "THIS WILL BE A TITLE IF NEEDED"
        graph.titleTextStyle = textStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchor.top

    }

    func configureChart() {
        let graph = containingView.hostedGraph!

        // Create the chart itself
        let pieChart = CPTPieChart()
        pieChart.delegate = self
        pieChart.dataSource = self
        pieChart.pieRadius = (min(containingView.bounds.size.width, containingView.bounds.size.height) * 0.7) / 2
        pieChart.identifier = NSString(string: graph.title!)
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
        return 3 // TODO Placeholder
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        return 10 // TODO Placeholder
    }
    
    func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
        let val = 10.0
        return CPTTextLayer(text: "Word: \(val)")
    }
      
    func sliceFill(for pieChart: CPTPieChart, record idx: UInt) -> CPTFill? {
        return CPTFill(color: CPTColor(componentRed: 0.92, green: 0.28, blue: 0.25, alpha: 1))
    }
      
    func legendTitle(for pieChart: CPTPieChart, record idx: UInt) -> String? {
      return nil
    }
}

// MARK: - TableView Extensions

extension BudgetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goal", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO add selection action?
    }
    
    
}
