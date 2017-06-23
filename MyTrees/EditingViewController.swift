//
//  EditingViewController.swift
//  MyTrees
//
//  Created by Eldien Hasmanto on 6/2/17.
//  Copyright © 2017 Eldien Hasmanto. All rights reserved.
//

import UIKit
import SQLite

class EditingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, deleteProtocol, createNewVoucher, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var items = ["No Data to Display"]
    var txt:NSNumber? = nil
    var trx = Dictionary<String, Dictionary<String,Any>>()
    var voucherTaxiArray = [Dictionary<String, String>]()
    var newVoucherTaxi = [Dictionary<String, String>]()
    var taxiMark = "0"
    
    let myPickerData = ["-Activity-", "Project", "Sales / Pre-sales", "Office"]
    var projectPickerData = [Dictionary<String,String>]()
    var customerPickerData = [Dictionary<String,String>]()
    var usePickerData = [Dictionary<String,String>]()
    
    var deletedRow = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var activityField: UITextField!
    @IBOutlet weak var projectField: UITextField!
    @IBOutlet weak var otherProjectField: UITextField!
    @IBOutlet weak var mealPrice: UITextField!
    @IBOutlet weak var parkingPrice: UITextField!
    @IBOutlet weak var tolOffice: UITextField!
    @IBOutlet weak var tolClient: UITextField!
    @IBOutlet weak var distanceField: UITextField!
    @IBOutlet weak var hiddenProjectCode: UILabel!
    @IBOutlet weak var voucherTable: UITableView!
    @IBOutlet weak var otherProjectFieldContraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var addTaxiBtn: UIButton!
    @IBOutlet weak var mealSwitch: UISwitch!
    @IBOutlet weak var personalSwitch: UISwitch!
    @IBOutlet weak var parkingSwitch: UISwitch!
    @IBOutlet weak var tollSwitch: UISwitch!
    @IBOutlet weak var taxiSwitch: UISwitch!
    
    var mealAmount: Int { return mealPrice.string.digits.integer }
    var tollOffamount: Int { return tolOffice.string.digits.integer }
    var tollCliamount: Int { return tolClient.string.digits.integer }
    var parkingAmount: Int { return parkingPrice.string.digits.integer }
    
    let disableColor = UIColor.init(colorLiteralRed: (240/255), green: (236/255), blue: (243/255), alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getClientLists()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditingViewController.doneToolbar))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditingViewController.doneToolbar))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        let mileageList = self.trx["mileage"]?["mileage_list"] as? [String:AnyObject]
        
        dateField.isUserInteractionEnabled = false
        dateField.backgroundColor = disableColor
        dateField.text = self.trx["mileage"]?["date"] as? String
        activityField.text = self.trx["mileage"]?["activity"] as? String
        if (activityField.text == "Office") {
            projectField.text = ""
            projectField.backgroundColor = disableColor
            projectField.isUserInteractionEnabled = false
        }
        hiddenProjectCode.text = self.trx["mileage"]?["project_code"] as? String
        distanceField.text = self.trx["mileage"]?["project_distance"] as? String
        if ((self.trx["mileage"]?["project_code"] as! String) == "Other") {
            otherProjectField.text = self.trx["mileage"]?["project"] as? String
            projectField.text = "Other"
            otherProjectFieldContraint.constant = 30
        } else {
            projectField.text = self.trx["mileage"]?["project"] as? String
            otherProjectFieldContraint.constant = 0
        }
        
        if (mileageList!["meal"]? .isEqual(to: ""))! {
            mealSwitch.isOn = false
            mealPrice.text = ""
        } else {
            mealSwitch.isOn = true
            mealPrice.text = mileageList?["meal"] as? String
        }
        
        if (mileageList!["parking"]? .isEqual(to: ""))! {
            parkingSwitch.isOn = false
            parkingPrice.text = ""
        } else {
            personalSwitch.isOn = true
            distanceField.alpha = 1
            parkingSwitch.isOn = true
            parkingPrice.text = mileageList?["parking"] as? String
        }
        
        if ((mileageList!["tol_office"]? .isEqual(to: ""))! && (mileageList!["tol_client"]? .isEqual(to: ""))!) {
            tollSwitch.isOn = false
            personalSwitch.isOn = false
            distanceField.alpha = 0
        } else {
            tollSwitch.isOn = true
            personalSwitch.isOn = true
            distanceField.alpha = 1
            if (mileageList!["tol_office"]? .isEqual(to: ""))! {
                tolOffice.text = ""
            } else {
                tolOffice.text = mileageList?["tol_office"] as? String
            }
            if (mileageList!["tol_client"]? .isEqual(to: ""))! {
                tolClient.text = ""
            } else {
                tolClient.text = mileageList?["tol_client"] as? String
            }
        }
        voucherTaxiArray.removeAll()
        voucherTaxiArray = mileageList?["taxies"] as! [Dictionary<String, String>]
        
        let projectPicker:UIPickerView = UIPickerView()
        projectPicker.tag = 1
        projectPicker.delegate = self
        projectPicker.dataSource = self
        activityField.inputView = projectPicker
        
        let newProjectPicker:UIPickerView = UIPickerView()
        newProjectPicker.tag = 2
        newProjectPicker.delegate = self
        newProjectPicker.dataSource = self
        projectField.inputView = newProjectPicker
        
        activityField.inputAccessoryView = toolBar
        projectField.inputAccessoryView = toolBar
        otherProjectField.inputAccessoryView = toolBar
        mealPrice.inputAccessoryView = toolBar
        parkingPrice.inputAccessoryView = toolBar
        tolClient.inputAccessoryView = toolBar
        tolOffice.inputAccessoryView = toolBar
        
        mealPrice.textAlignment = .right
        mealPrice.text = Formatter.decimal.string(from: mealAmount as NSNumber)
        tolOffice.textAlignment = .right
        tolOffice.text = Formatter.decimal.string(from: tollOffamount as NSNumber)
        tolClient.textAlignment = .right
        tolClient.text = Formatter.decimal.string(from: tollCliamount as NSNumber)
        parkingPrice.textAlignment = .right
        parkingPrice.text = Formatter.decimal.string(from: parkingAmount as NSNumber)
    }
    
    func doneToolbar () {
        activityField.resignFirstResponder()
        projectField.resignFirstResponder()
        otherProjectField.resignFirstResponder()
        mealPrice.resignFirstResponder()
        parkingPrice.resignFirstResponder()
        tolClient.resignFirstResponder()
        tolOffice.resignFirstResponder()
    }
    
    @IBAction func activityEditEnd(_ sender: UITextField) {
        if (sender.text == "Office") {
            projectField.text = ""
            projectField.isUserInteractionEnabled = false
            projectField.backgroundColor = disableColor
        } else {
            projectField.isUserInteractionEnabled = true
            projectField.backgroundColor = UIColor.clear
            if (sender.text == "Project") {
                usePickerData = projectPickerData
            } else {
                usePickerData = customerPickerData
            }
        }
    }
    
    @IBAction func taxiSwitched(_ sender: UISwitch) {
        if (sender.isOn) {
            voucherTable.isUserInteractionEnabled = true
            addTaxiBtn.isEnabled = true
        } else {
            voucherTable.isUserInteractionEnabled = false
            addTaxiBtn.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let newData = ["code": "dummy", "name": "-Select One-", "distance": "0"]
        customerPickerData.append(newData)
        projectPickerData.append(newData)
        
//        if (newVoucherTaxi.count) > 0 {
//            let voucherIndex = (newVoucherTaxi.count) - 1
//            voucherTaxiArray.append(newVoucherTaxi[voucherIndex])
//        }
        tableView.reloadData()
    }
    
    func deleteRowWithId (value: String) {
        if (!deletedRow.contains(value)) {
            deletedRow.append(value)
        }
    }
    
    func deleteRowat(value: String) {
        self.voucherTaxiArray.remove(at: Int(value)!)
    }
    
    func createNewVoucherRow(voucher: [String:String]) {
        self.newVoucherTaxi.append(voucher)
        voucherTaxiArray.append(voucher)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func mealPriceChanged(_ sender: UITextField) {
        sender.text = Formatter.decimal.string(from: mealAmount as NSNumber)
    }
    
    @IBAction func tolOfficeChanged(_ sender: UITextField) {
        sender.text = Formatter.decimal.string(from: tollOffamount as NSNumber)
    }
    
    @IBAction func tolClientChanged(_ sender: UITextField) {
        sender.text = Formatter.decimal.string(from: tollCliamount as NSNumber)
    }
    
    @IBAction func parkingChanged(_ sender: UITextField) {
        sender.text = Formatter.decimal.string(from: parkingAmount as NSNumber)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 1) {
            return myPickerData.count
        } else {
            return usePickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.tag == 1){
            return myPickerData[row]
        } else {
            return usePickerData[row]["name"]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 1) {
            activityField.text = myPickerData[row]
        } else {
            projectField.text = usePickerData[row]["name"]
            distanceField.text = usePickerData[row]["distance"]
            hiddenProjectCode.text = usePickerData[row]["code"]
        }
        
    }
    
    @IBAction func goUpdate(_ sender: Any) {
        for newVoucher in voucherTaxiArray {
            if (newVoucher["voucher_id"] == nil) {
                addNewTaxiVoucher(data: newVoucher)
            }
        }
        if (deletedRow.count > 0) {
            for i in 0 ..< deletedRow.count {
                print("delete: \(deletedRow[i])")
                deleteTaxiRow(id: Int64(deletedRow[i])!)
            }
        }
        
//        if (deletedRow.count) > 0 {
//            deleteTaxiRow(id: Int64(deletedRow[0])!)
//        }
//        if (newVoucherTaxi.count) > 0 {
//            for vouchers in newVoucherTaxi {
//                addNewTaxiVoucher(data: vouchers)
//            }
//        }
        
        var projectTyped = ""
        if (projectField.text == "Other") {
            projectTyped = otherProjectField.text!
            hiddenProjectCode.text = "Other"
        } else {
            projectTyped = projectField.text!
        }
        
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let mileageDb = try Connection("\(path)/db.sqlite3")
            let users = Table("dummy_devs")
            let id = Expression<Int64>("id")
            let name = Expression<String>("name")
            let new_date = Expression<String>("date")
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
            let trx = users.filter(id == ((self.trx["mileage"]?["id"]) as! Int64))
            let update =
                trx.update(new_date <- dateField.text!,
                           project <- projectTyped,
                           project_code <- hiddenProjectCode.text!,
                           project_distance <- distanceField.text!,
                           meal <- String(describing: mealAmount),
                           parking <- String(describing: parkingAmount),
                           toll_office <- String(describing: tollOffamount),
                           toll_client <- String(describing: tollCliamount))
            
            _ = try mileageDb.run(update)
            saveSuccess()
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }

    }
    
    func addNewTaxiVoucher (data: Dictionary<String,String>) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let mileageDb = try Connection("\(path)/db.sqlite3")
            
            let taxi_table = Table("dummy_taxi_devs")
            let voucher_id = Expression<Int64>("id")
            let taxi_voucher = Expression<String>("voucher_id")
            let taxi_from = Expression<String>("taxi_from")
            let taxi_to = Expression<String>("taxi_to")
            let taxi_amount = Expression<String>("taxi_amount")
            let taxi_time = Expression<String>("taxi_time")
            let trx_ids = Expression<String>("trx_id")
            
            
            try mileageDb.run(taxi_table.create(ifNotExists:true) { t in
                t.column(voucher_id, primaryKey: true)
                t.column(taxi_voucher)
                t.column(taxi_from)
                t.column(taxi_to)
                t.column(taxi_amount)
                t.column(taxi_time)
                t.column(trx_ids)
            })
            
            let taxiInsert = taxi_table.insert(taxi_voucher <- data["voucher_number"]!,
                                               taxi_amount <- data["price"]!,
                                               taxi_from <- data["from"]!,
                                               taxi_to <- data["to"]!,
                                               taxi_time <- data["time"]!,
                                               trx_ids <- data["trx_id"]!)
            
            _ = try mileageDb.run(taxiInsert)
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }

    }
    
    func deleteTaxiRow (id: Int64) {
        print("deleting taxi voucher with id \(id)")
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let mileageDb = try Connection("\(path)/db.sqlite3")
            
            let taxi_table = Table("dummy_taxi_devs")
            let voucher_id = Expression<Int64>("id")
            
            let deleteThisRow = taxi_table.filter(voucher_id == id)
            try mileageDb.run(deleteThisRow.delete())
            
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
            
            if (hiddenProjectCode.text?.contains("P"))! {
                print("its P")
                usePickerData = projectPickerData
            } else {
                usePickerData = customerPickerData
            }
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }
    }
    
    @IBAction func addNewVoucher(_ sender: Any) {
        let nextViewController = storyboard?.instantiateViewController(withIdentifier: "addNewVoucher") as! VoucherAddNewViewController
        nextViewController.trx_id = String(describing: (self.trx["mileage"]?["id"] as! Int64))
        nextViewController.myProtocol = self
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier?.contains("addNewVoucher"))!{
            if let destination = segue.destination as? VoucherAddNewViewController {
                destination.trx_id = String(trx["mileage"]?["id"] as! Int64)
            }
        } else {
            print("Identifier not match!!")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
//        print(self.voucherTaxiArray[indexPath.row]["row"]!)
        let nextViewController = storyboard?.instantiateViewController(withIdentifier: "deleteViewController") as! VoucherEditViewController
        nextViewController.myDeleteProtocol = self
        nextViewController.voucherID = String(indexPath.row)
        nextViewController.voucherTaxies = self.voucherTaxiArray[indexPath.row]
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
//        self.performSegue(withIdentifier: "viewOrDeleteVoucher", sender: self.voucherTaxiArray[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(voucherTaxiArray.count == 0) {
            return self.items.count
        } else {
            return (self.voucherTaxiArray.count);
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if (voucherTaxiArray.count > 0) {
            if (self.voucherTaxiArray[indexPath.row]["markDelete"] != nil) {
                let priceValue = self.voucherTaxiArray[indexPath.row]["price"]
                print("this \(priceValue ?? "EMPTY VALUE") row had to be deleted")
            } else if (self.voucherTaxiArray[indexPath.row]["markDelete"] == nil) {
                cell.textLabel?.text = self.voucherTaxiArray[indexPath.row]["voucher_number"]!
                cell.detailTextLabel?.text = self.voucherTaxiArray[indexPath.row]["price"]!
            }
        } else {
            cell.textLabel?.text = self.items[indexPath.row]
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    func saveSuccess () {
        let alertController = UIAlertController(title: "Success", message: "Your changes has been saved", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func mealTurned(_ sender: UISwitch) {
        if (!sender.isOn) {
            mealPrice.isUserInteractionEnabled = false
            mealPrice.backgroundColor = disableColor
        } else {
            mealPrice.isUserInteractionEnabled = true
            mealPrice.backgroundColor = UIColor.clear
        }
    }
    
    @IBAction func personalTurned(_ sender: UISwitch) {
        if (sender.isOn) {
            parkingSwitch.isUserInteractionEnabled = true
            parkingPrice.isUserInteractionEnabled = true
            tollSwitch.isUserInteractionEnabled = true
            tolClient.isUserInteractionEnabled = true
            tolOffice.isUserInteractionEnabled = true
            distanceField.isUserInteractionEnabled = true
            
            distanceField.backgroundColor = UIColor.clear
        } else {
            distanceField.isUserInteractionEnabled = false
            distanceField.backgroundColor = disableColor
            parkingSwitch.isOn = false
            parkingSwitch.isUserInteractionEnabled = false
            parkingPrice.isUserInteractionEnabled = false
            parkingPrice.backgroundColor = disableColor
            tollSwitch.isOn = false
            tollSwitch.isUserInteractionEnabled = false
            tolClient.isUserInteractionEnabled = false
            tolClient.backgroundColor = disableColor
            tolOffice.isUserInteractionEnabled = false
            tolOffice.backgroundColor = disableColor
        }
    }
    
    @IBAction func parkingTurned(_ sender: UISwitch) {
        if (sender.isOn) {
            parkingPrice.isUserInteractionEnabled = true
            parkingPrice.backgroundColor = UIColor.clear
        } else {
            parkingPrice.isUserInteractionEnabled = false
            parkingPrice.backgroundColor = disableColor
        }
    }
    
    @IBAction func tolTurned(_ sender: UISwitch) {
        if (sender.isOn) {
            tolOffice.isUserInteractionEnabled = true
            tolClient.isUserInteractionEnabled = true
            tolOffice.backgroundColor = UIColor.clear
            tolClient.backgroundColor = UIColor.clear
        } else {
            tolOffice.isUserInteractionEnabled = false
            tolClient.isUserInteractionEnabled = false
            tolOffice.backgroundColor = disableColor
            tolClient.backgroundColor = disableColor
        }
    }
    
}

