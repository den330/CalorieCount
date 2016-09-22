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
        modalPresentationStyle = .custom
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
        let when = DispatchTime.now() + Double(Int64(delayInSeconds*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: when){
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func close(){
        dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DetailPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}




extension DetailViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return(touch.view === self.view)
    }
}


extension DetailViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake{
            showEmail()
        }
    }
    
    func showEmail(){
        if presentedViewController != nil{
            dismiss(animated: true,completion: nil)
        }
        makeEmail()
    }
    
    func makeEmail(){
        if MFMailComposeViewController.canSendMail(){
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject(NSLocalizedString("New Feature Idea", comment: "Email Sub"))
            controller.setToRecipients(["yaxinyuan0910@gmail.com"])
            present(controller, animated: true, completion: nil)
        }
    }
}
