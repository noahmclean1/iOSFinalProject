//
//  ColorProtocol.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/13/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import Foundation
import UIKit

protocol ColorProtocol: class {
    func setColor(color: UIColor) -> Void
}

protocol NewGoalDelegate: class {
    func reloadGoals() -> Void
}

protocol NewTransDelegate: class {
    func reloadTrans() -> Void
    func filterTrans(year: Int, month: Int) -> Void
}


