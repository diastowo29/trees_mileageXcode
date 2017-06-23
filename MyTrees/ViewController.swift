//
//  ViewController.swift
//  MyTrees
//
//  Created by Eldien Hasmanto on 5/4/17.
//  Copyright © 2017 Eldien Hasmanto. All rights reserved.
//

import UIKit
import SQLite

class ViewController: BaseViewController , UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet weak var dateToField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var projectField: UITextField!
    @IBOutlet weak var statusField: UITextField!
    @IBOutlet weak var hiddenProjectCode: UILabel!
    
    let myPickerData = ["-Project List-", "IDSmed", "Fif Group", "Tiki Raden Saleh", "Wika Group", "Other"]
    let statusData = ["-Select One-", "Cuti", "Sakit"]
    
    var projectPickerData = [Dictionary<String,String>]()
    var customerPickerData = [Dictionary<String,String>]()
    var usePickerData = [Dictionary<String,String>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
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
        
        dateField.inputAccessoryView = toolBar
        dateToField.inputAccessoryView = toolBar
        projectField.inputAccessoryView = toolBar
        statusField.inputAccessoryView = toolBar
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func donePicker () {
        dateField.resignFirstResponder()
        dateToField.resignFirstResponder()
        projectField.resignFirstResponder()
        statusField.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getClientLists()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showDate(_ sender: UITextField) {
        let datePicker:UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePicker
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: UIControlEvents.valueChanged)
    }
    @IBAction func showToDate(_ sender: UITextField) {
        let datePicker:UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePicker
        datePicker.addTarget(self, action: #selector(handleDateToPicker), for: UIControlEvents.valueChanged)
    }
    
    func handleDatePicker (sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .long
        dateField.text = timeFormatter.string(from: sender.date)
    }
    
    func handleDateToPicker (sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .long
        dateToField.text = timeFormatter.string(from: sender.date)
    }

    @IBAction func onTap(_ sender: Any) {
        dateField.resignFirstResponder()
        dateToField.resignFirstResponder()
        projectField.resignFirstResponder()
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
    
    @IBAction func doSave(_ sender: UIBarButtonItem) {
        if (checkDuplicateRow() > 0) {
            errorDuplicate()
        } else {
            if ((statusField.text?.isEmpty)!) {
                errorDataEmpty()
            } else {
                dbProcess()
            }
        }
    }
    
    func errorDuplicate () {
        let duplicateAlertContr = UIAlertController(title: "Error", message: "Row with same Date and Project is already exist.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            duplicateAlertContr.dismiss(animated: true, completion: nil)}
        duplicateAlertContr.addAction(confirmAction)
        present(duplicateAlertContr, animated: true, completion: nil)
    }
    
    func errorDataEmpty () {
        let duplicateAlertContr = UIAlertController(title: "Error", message: "Some field is empty", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            duplicateAlertContr.dismiss(animated: true, completion: nil)}
        duplicateAlertContr.addAction(confirmAction)
        present(duplicateAlertContr, animated: true, completion: nil)
    }
    
    @IBAction func fromDidBegin(_ sender: UITextField) {
        giveTodayDate(sender: sender)
    }
    
    @IBAction func toDidBegin(_ sender: UITextField) {
        giveTodayDate(sender: sender)
    }
    
    
    func giveTodayDate (sender: UITextField) {
        let uiDate = UIDatePicker()
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .long
        if (sender.text?.isEmpty)! {
            sender.text = timeFormatter.string(from: uiDate.date)
        }
    }
    
    func dbProcess() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let mileageDb = try Connection("\(path)/db.sqlite3")
            let users = Table("dummy_devs")
            let id = Expression<Int64>("id")
            let name = Expression<String>("name")
            let new_date = Expression<String>("date")
            let activity = Expression<String>("activity")
            let project = Expression<String>("project")
            let project_code = Expression<String>("project_code")
            let project_distance = Expression<String>("project_distance")
            let meal = Expression<String>("meal")
            let parking = Expression<String>("parking")
            let toll_office = Expression<String>("toll_office")
            let toll_client = Expression<String>("toll_client")
            let tag = Expression<String>("tag")
            let leave_from = Expression<String>("leave_from")
            let leave_to = Expression<String>("leave_to")
            let leave_project = Expression<String>("leave_project")
            let leave_stats = Expression<String>("leave_stats")
            
            try mileageDb.run(users.create(ifNotExists:true) { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(new_date)
                t.column(activity)
                t.column(project)
                t.column(project_code)
                t.column(project_distance)
                t.column(meal)
                t.column(parking)
                t.column(toll_office)
                t.column(toll_client)
                t.column(tag)
                t.column(leave_from)
                t.column(leave_to)
                t.column(leave_project)
                t.column(leave_stats)
            })
            
            let insert =
                users.insert(name <- SomethingAwesome.usercode,
                             activity <- "",
                             new_date <- dateField.text!,
                             project <- projectField.text!,
                             project_code <- hiddenProjectCode.text!,
                             project_distance <- "",
                             meal <- "",
                             parking <- "",
                             toll_office <- "",
                             toll_client <- "",
                             tag <- "leave",
                             leave_from <- "",
                             leave_to <- dateToField.text!,
                             leave_project <- "",
                             leave_stats <- statusField.text!)
            try mileageDb.run(insert)
            saveSuccess()
            
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }
    }
    
    func saveSuccess () {
        let alertController = UIAlertController(title: "Success", message: "Your changes has been saved", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
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
    
    func checkDuplicateRow () -> Int{
        var count = 0
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let mileageDb = try Connection("\(path)/db.sqlite3")
            let users = Table("dummy_devs")
            let id = Expression<Int64>("id")
            let name = Expression<String>("name")
            let new_date = Expression<String>("date")
            let activity = Expression<String>("activity")
            let project = Expression<String>("project")
            let project_code = Expression<String>("project_code")
            let project_distance = Expression<String>("project_distance")
            let meal = Expression<String>("meal")
            let parking = Expression<String>("parking")
            let toll_office = Expression<String>("toll_office")
            let toll_client = Expression<String>("toll_client")
            let tag = Expression<String>("tag")
            let leave_from = Expression<String>("leave_from")
            let leave_to = Expression<String>("leave_to")
            let leave_project = Expression<String>("leave_project")
            let leave_stats = Expression<String>("leave_stats")
            
            try mileageDb.run(users.create(ifNotExists:true) { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(new_date)
                t.column(activity)
                t.column(project)
                t.column(project_code)
                t.column(project_distance)
                t.column(meal)
                t.column(parking)
                t.column(toll_office)
                t.column(toll_client)
                t.column(tag)
                t.column(leave_from)
                t.column(leave_to)
                t.column(leave_project)
                t.column(leave_stats)
            })
            
            count = try mileageDb.scalar(users.filter(new_date == dateField.text!)
                .filter(tag == "leave")
                .filter(project == projectField.text!).count)
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }
        return count
    }
}

