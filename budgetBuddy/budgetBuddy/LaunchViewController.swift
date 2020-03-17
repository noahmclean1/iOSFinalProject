//
//  LaunchViewController.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/17/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var version: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let chartIcon = UIImage(named: "chart")
        
        backImage.image = chartIcon
        version.text = appVersion
        
        perform(#selector(self.proceed), with: nil, afterDelay: 2)
    }
    
    @objc func proceed() {
        performSegue(withIdentifier: "Start", sender: self)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
