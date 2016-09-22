//
//  ViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/11.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class CalorieCountViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    var managedContext: NSManagedObjectContext!
    var NaviController: UINavigationController?
    var didTip = false
    var pendingFav: Food!
    var recentDay: Day!
    var itemForSelected: ItemConsumed!
    
    
    
    @IBOutlet weak var filterHeight: NSLayoutConstraint!
    @IBOutlet weak var filterTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let net = NetworkGrab()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(CalorieCountViewController.handleLongPress))
        tableView.addGestureRecognizer(longPress)
        longPress.cancelsTouchesInView = true
        let slideToRight = UISwipeGestureRecognizer(target: self, action: #selector(CalorieCountViewController.handleSwipe))
        tableView.addGestureRecognizer(slideToRight)
        slideToRight.cancelsTouchesInView = true
        tableView.contentInset = UIEdgeInsets(top: commonConstants.topInsets, left: 0, bottom: 0, right: 0)
        let cellNib = UINib(nibName: commonConstants.cellXib, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: commonConstants.cellXib)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "said it before") == false{
            let message = "For complete and the most up-to-date manual, click 'Manual' in Fav Tab"
            makeAlert(message, vc: self, title: "Tips")
            UserDefaults.standard.set(true, forKey: "said it before")
        }
    }
    
    func makeFavAlert(){
        let alert = UIAlertController(title: "Favorite", message: "Add to Favorite", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Add it!", style: .default, handler: {[unowned self] _ in self.handleFav()}))
        alert.addAction(UIAlertAction(title: "Don't!", style: .default, handler: nil))
        present(alert,animated: true, completion: nil)
        alert.view.tintColor = UIColor.red
    }
    
    func handleFav(){
        let fetchRequest = NSFetchRequest(entityName: "ItemConsumed")
        fetchRequest.predicate = NSPredicate(format: "isFav==%@", true)
        var results:[ItemConsumed]?
        do{
            results = try managedContext.fetch(fetchRequest) as? [ItemConsumed]
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        guard let lst = results else{
            print("Wrong")
            return
        }
        for i in lst{
            if i.id == pendingFav.id{
                makeAlertNoButton("This Item Is Already In Fav", vc: self, title: "Already There")
                dismissPopup(self, time: 1.0)
                return
            }
        }
        makeAlertNoButton("Successfully Added To Fav", vc: self, title: "Added")
        dismissPopup(self, time: 1.0)
        let itemEntity = NSEntityDescription.entity(forEntityName: "ItemConsumed", in: managedContext)!
        let favFood = ItemConsumed(entity: itemEntity, insertInto: managedContext)
        favFood.brand = pendingFav.brandContent
        favFood.id = pendingFav.id
        favFood.isFav = true
        favFood.name = pendingFav.foodContent
        favFood.quantity = String(pendingFav.quantity) + " " + pendingFav.unit
        favFood.quantityConsumed = 0
        favFood.totalCalories = 0
        favFood.unitCalories = pendingFav.caloriesCount
        do{
            try managedContext.save()
        }catch{
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch net.state{
            case .notFound, .searching: return 1
            case .notSearchedYet: return 1
            case .searchSuccess(let lst): return lst.count
            case .noConnection: return 1
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: commonConstants.cellXib, for: indexPath) as! FoodCell
        cell.selectionStyle = .none
        switch net.state{
            case .searchSuccess(let lst):
                cell.selectionStyle = .default
                let foodItem = lst[(indexPath as NSIndexPath).row]
                configureCell(cell, foodContent: foodItem.foodContent, caloriesContent: foodItem.caloriesCount, brandContent: foodItem.brandContent,quantityContent: foodItem.quantity,unitContent: foodItem.unit)
                return cell
            case .notFound:
                configureCell(cell, foodContent: "NA", caloriesContent: 0,brandContent: "NA",quantityContent: nil,unitContent: nil)
            case .noConnection:
                configureCell(cell, foodContent: "No Connection", caloriesContent: 0, brandContent: "NA", quantityContent: nil, unitContent: nil)
            case .searching:
                configureCell(cell, foodContent: "Searching", caloriesContent: 0, brandContent: "Searching",quantityContent: nil,unitContent: nil)
            case .notSearchedYet:
                configureCell(cell, foodContent: "Click Search bar to start search", caloriesContent: 0, brandContent: "", quantityContent: nil,unitContent: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch net.state{
            case .searchSuccess( _):
                return indexPath
            default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showDetail", sender: indexPath)
    }
    
    func handleLongPress(_ sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                if let lst = net.state.get(){
                    pendingFav = lst[(indexPath as NSIndexPath).row]
                    makeFavAlert()
                }
            }
        }
    }
    
    func quickSave(_ indexPath: IndexPath){
        if let lst = net.state.get(){
            let food = lst[(indexPath as NSIndexPath).row]
            save(managedContext, food: food, quantity: 1)
            let hudView: HudView = HudView.hudInView(view, animated: true)
            hudView.text = "1 Unit Saved"
            let cell = tableView.cellForRow(at: indexPath) as! FoodCell
            let storedCal = cell.calorieLabel.text
            cell.calorieLabel.text = "1 Unit Added"
            postNotification()
            let delayInSeconds = 0.6
            let when = DispatchTime.now() + Double(Int64(delayInSeconds*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: when){
                hudView.removeFromSuperview()
                cell.calorieLabel.text = storedCal
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func handleSwipe(_ sender: UISwipeGestureRecognizer){
        if sender.direction == .right{
            let slidePoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: slidePoint){
                quickSave(indexPath)
            }
        }
    }
    
    



    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            let detailController = segue.destination as! DetailViewController
            let index = sender as! IndexPath
            if let lst = net.state.get(){
                detailController.foodSelected = lst[(index as NSIndexPath).row]
                detailController.managedContext = managedContext
                detailController.fromMain = true
            }
        }
    }
}

extension CalorieCountViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        let text = searchBar.text!
        let filtertext = filterTextField.text!
        if text != ""{
            net.performSearch(text, filterText: filtertext){
                self.tableView.reloadData()
            }
            tableView.reloadData()
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension CalorieCountViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            searchBarSearchButtonClicked(searchBar)
            textField.resignFirstResponder()
            return false
    }
}

extension CalorieCountViewController: MFMailComposeViewControllerDelegate{
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
            controller.setSubject(NSLocalizedString("App Suggestion", comment: "Email Sub"))
            controller.setToRecipients(["yaxinyuan0910@gmail.com"])
            present(controller, animated: true, completion: nil)
        }
    }
}






