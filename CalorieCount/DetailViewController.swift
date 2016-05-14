//
//  DetailViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/13.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    var foodSelected: Food?
    var managedContext: NSManagedObjectContext!
    
    @IBOutlet weak var quantityLabel: UILabel!
    var currentfigure = 0
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(foodSelected?.foodContent)
    }
    
    @IBAction func addButton(){
        currentfigure = Int(quantityLabel.text!)!
        currentfigure += 1
        quantityLabel.text = String(currentfigure)
    }
    
    @IBAction func minusButton(){
        currentfigure = Int(quantityLabel.text!)!
        if currentfigure > 0{
            currentfigure -= 1
            quantityLabel.text = String(currentfigure)
        }
    }
    
    @IBAction func saveButton(){
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func close(){
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate{
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DetailPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}
