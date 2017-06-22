//
//  EditingAbsenceViewController.swift
//  MyTrees
//
//  Created by Eldien Hasmanto on 6/6/17.
//  Copyright © 2017 Eldien Hasmanto. All rights reserved.
//

import UIKit
import SQLite

class EditingAbsenceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var trx = Dictionary<String, Dictionary<String,Any>>()
    
    @IBOutlet weak var dateFrom: UITextField!
    @IBOutlet weak var dateTo: UITextField!
    @IBOutlet weak var projectField: UITextField!
    @IBOutlet weak var statusField: UITextField!
    @IBOutlet weak var hiddenProjectCode: UILabel!
    
    let statusData = ["-Chose one-", "Cuti", "Sakit"]
    var projectPickerData = [Dictionary<String,String>]()
    var customerPickerData = [Dictionary<String,String>]()
    var usePickerData = [Dictionary<String,String>]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("absence")
        print(trx)
        
        dateFrom.text = trx["mileage"]?["date"] as? String
        dateTo.text = trx["mileage"]?["leave_to"] as? String
        projectField.text = trx["mileage"]?["project"] as? String
        statusField.text = trx["mileage"]?["leave_stats"] as? String
        
        let projectPicker:UIPickerView = UIPickerView()
        projectField.inputView = projectPicker
        projectPicker.delegate = self
        projectPicker.dataSource = self
        projectPicker.tag = 1
        
        let statusPicker:UIPickerView = UIPickerView()
        statusField.inputView = statusPicker
        statusPicker.delegate = self
        statusPicker.dataSource = self
        statusPicker.tag = 2
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        dateFrom.inputAccessoryView = toolBar
        dateTo.inputAccessoryView = toolBar
        projectField.inputAccessoryView = toolBar
        statusField.inputAccessoryView = toolBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getClientLists()
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
    
    func getClientLists () {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let mileageDb = try Connection("\(path)/db.sqlite3")
            let users = Table("dummy_lists")
            let id = Expression<Int64>("id")
            let list_code = Expression<String>("code")
            let list_name = Expression<String>("name")
            let list_distance = Expression<String>("distance")
            let list_type = Expression<String>("type")
            
            try mileageDb.run(users.create(ifNotExists:true) { t in
                t.column(id, primaryKey: true)
                t.column(list_code)
                t.column(list_name)
                t.column(list_distance)
                t.column(list_type)
            })
            
            for user in try mileageDb.prepare(users) {
                if (user[list_type] == "projects") {
                    let newData = ["code": user[list_code], "name": user[list_name], "distance": user[list_distance]]
                    projectPickerData.append(newData)
                }
                if (user[list_type] == "customers") {
                    let newData = ["code": user[list_code], "name": user[list_name], "distance": user[list_distance]]
                    customerPickerData.append(newData)
                }
            }
            let otherData = ["code": "other", "name": "Other", "distance": "0"]
            projectPickerData.append(otherData)
            customerPickerData.append(otherData)
            
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 1) {
            return projectPickerData.count
        } else {
            return statusData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.tag == 1){
            return projectPickerData[row]["name"]
        } else {
            return statusData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 1) {
            projectField.text = projectPickerData[row]["name"]
            hiddenProjectCode.text = projectPickerData[row]["code"]
        } else {
            statusField.text = statusData[row]
        }
    }
    
}
