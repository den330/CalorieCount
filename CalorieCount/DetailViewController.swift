//
//  DetailViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/13.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class DetailViewController: UIViewController {
    
    var foodSelected: Food!
    var managedContext: NSManagedObjectContext!
    var recentDay: Day!
    var itemForSelected: ItemConsumed!
    var itemCon: ItemConsumed!
    let transition = DetailAnimationController()
    var fromMain = false
    
    @IBOutlet weak var quantityLabel: UILabel!
    var currentfigure = 1
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        transition.presenting = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.close))
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    @IBAction func addButton(){
        currentfigure = Int(quantityLabel.text!)!
        currentfigure += 1
        quantityLabel.text = String(currentfigure)
    }
    
    @IBAction func minusButton(){
        currentfigure = Int(quantityLabel.text!)!
        if currentfigure > 1{
            currentfigure -= 1
            quantityLabel.text = String(currentfigure)
        }
    }
    
    @IBAction func saveButton(){
        let hudView = HudView.hudInView(view, animated: true)
        hudView.text = "Saved"
        if fromMain{
            save(managedContext, food: foodSelected, quantity: currentfigure)
        }else{
            save(managedContext, food: itemCon, quantity: currentfigure)
        }
        postNotification()
        let delayInSeconds = 0.6
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds*Double(NSEC_PER_SEC)))
        dispatch_after(when, dispatch_get_main_queue()){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func close(){
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate{
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DetailPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}




extension DetailViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return(touch.view === self.view)
    }
}


extension DetailViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake{
            showEmail()
        }
    }
    
    func showEmail(){
        if presentedViewController != nil{
            dismissViewControllerAnimated(true,completion: nil)
        }
        makeEmail()
    }
    
    func makeEmail(){
        if MFMailComposeViewController.canSendMail(){
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject(NSLocalizedString("New Feature Idea", comment: "Email Sub"))
            controller.setToRecipients(["yaxinyuan0910@gmail.com"])
            presentViewController(controller, animated: true, completion: nil)
        }
    }
}
