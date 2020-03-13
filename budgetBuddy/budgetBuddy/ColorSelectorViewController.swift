//
//  ColorSelectorViewController.swift
//  budgetBuddy
//
//  Created by Noah McLean on 3/12/20.
//  Copyright © 2020 Noah McLean. All rights reserved.
//

import UIKit

class ColorSelectorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionColors: UICollectionView!
    @IBOutlet weak var flowlayout: UICollectionViewFlowLayout!
    
    var colors = [UIColor]()
    var tag = 0
    weak var delegate: ColorProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load in the colors from our saved plist
        let path = Bundle.main.path(forResource: "colors", ofType: "plist")
        let savedArray = NSArray(contentsOfFile: path!) as! [String]
        for colString in savedArray {
            colors.append(htmlToColor(color: colString))
        }
        
        // Set up the CollectionView
        collectionColors.delegate = self
        collectionColors.dataSource = self
        flowlayout.minimumLineSpacing = 1
        flowlayout.minimumInteritemSpacing = 1
        flowlayout.estimatedItemSize = CGSize(width: 25, height: 20)
        flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 5)
        //flowlayout.itemSize = CGSize(width: 25, height: 25)
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
        
        return UIColor(displayP3Red: CGFloat(rval)/255.0, green: CGFloat(gval)/255.0, blue: CGFloat(bval)/255.0, alpha: 1.0)
    }
    
    // MARK: - Collection View Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return 10
    }
       
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return 16
    }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "color", for: indexPath)
        if tag < colors.count {
            cell.tag = tag
            cell.backgroundColor = colors[tag]
            tag += 1
        }
        //cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: 25, height: 25)
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        delegate?.setColor(color: cell.backgroundColor!)
        //print("Selected: \(cell?.backgroundColor ?? .clear)")
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
