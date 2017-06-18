//
//  EditingAbsenceViewController.swift
//  MyTrees
//
//  Created by Eldien Hasmanto on 6/6/17.
//  Copyright © 2017 Eldien Hasmanto. All rights reserved.
//

import UIKit
import SQLite

class EditingAbsenceViewController: UIViewController {
    
    var trx = Dictionary<String, Dictionary<String,Any>>()
    
    @IBOutlet weak var dateFrom: UITextField!
    @IBOutlet weak var dateTo: UITextField!
    @IBOutlet weak var projectField: UITextField!
    @IBOutlet weak var statusField: UITextField!
    @IBOutlet weak var hiddenProjectCode: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("absence")
        print(trx)
        
        dateFrom.text = trx["mileage"]?["date"] as? String
        dateTo.text = trx["mileage"]?["leave_to"] as? String
        projectField.text = trx["mileage"]?["project"] as? String
        statusField.text = trx["mileage"]?["leave_stats"] as? String
    }
    
    @IBAction func saveAbsence(_ sender: Any) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let mileageDb = try Connection("\(path)/db.sqlite3")
            let users = Table("dummy_devs")
            let id = Expression<Int64>("id")
            let new_date = Expression<String>("date")
            let project = Expression<String>("project")
            let leave_to = Expression<String>("leave_to")
            let leave_stats = Expression<String>("leave_stats")
            
            let trxUpdate = users.filter(id == trx["mileage"]?["id"] as! Int64)
            try mileageDb.run(trxUpdate.update(project <- projectField.text!,
                                               new_date <- dateFrom.text!,
                                               leave_to <- dateTo.text!,
                                               leave_stats <- statusField.text!))
            
            _ = navigationController?.popViewController(animated: true)
            let myClaim = MyClaimViewController()
            myClaim.getList()
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }
    }
}
