
import UIKit
import SQLite
import Foundation

class MileageViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, createNewVoucherMileage {

    let myPickerData = ["-Activity-", "Project", "Sales / Pre-sales", "Office"]
    var projectPickerData = [Dictionary<String,String>]()
    var customerPickerData = [Dictionary<String,String>]()
    var usePickerData = [Dictionary<String,String>]()
    var items = ["No Data to Display"]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var childView: UIView!
    
    var voucherTaxiArray = [Dictionary<String, String>]()
    var mileageArray = [Dictionary<String, String>]()

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var projectListField: UITextField!
    @IBOutlet weak var activityField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var otherProjectField: UITextField!
    @IBOutlet weak var mealFIeld: UITextField!
    @IBOutlet weak var parkingField: UITextField!
    @IBOutlet weak var tolFromOfficeField: UITextField!
    @IBOutlet weak var tolFromClientField: UITextField!
    @IBOutlet weak var distanceField: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var hiddenProjectCode: UILabel!
    
    @IBOutlet weak var otherProjectFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var mealPriceHeight: NSLayoutConstraint!
    @IBOutlet weak var parkingPriceHeight: NSLayoutConstraint!
    @IBOutlet weak var tolContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var taxiContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var childViewHeight: NSLayoutConstraint!
    @IBOutlet weak var taxiVoucherTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tolContainer: UIView!
    @IBOutlet weak var taxiContainer: UIView!
    @IBOutlet weak var voucherStack: UIStackView!
    @IBOutlet weak var taxiVoucherTable: UIView!
    
    @IBOutlet weak var parkingSwitch: UISwitch!
    @IBOutlet weak var tolSwitch: UISwitch!
    @IBOutlet weak var taxiSwitch: UISwitch!
    @IBOutlet weak var addTaxiButton: UIButton!
    
    var voucherTaxiDict = Dictionary<String,String>()
    
    let disableColor = UIColor.init(colorLiteralRed: (240/255), green: (236/255), blue: (243/255), alpha: 1)
    
    override func viewDidLoad() {
        voucherTaxiArray.removeAll()
        super.viewDidLoad()
        self.addSlideMenuButton()
        
        projectListField.isUserInteractionEnabled = false
        projectListField.backgroundColor = disableColor
        parkingSwitch.isEnabled = false
        tolSwitch.isEnabled = false
        
        let projectPicker:UIPickerView = UIPickerView()
        projectPicker.tag = 1
        projectPicker.delegate = self
        projectPicker.dataSource = self
        activityField.inputView = projectPicker

        let newProjectPicker:UIPickerView = UIPickerView()
        newProjectPicker.tag = 2
        newProjectPicker.delegate = self
        newProjectPicker.dataSource = self
        projectListField.inputView = newProjectPicker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MileageViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MileageViewController.donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        projectListField.inputAccessoryView = toolBar
        activityField.inputAccessoryView = toolBar
        mealFIeld.inputAccessoryView = toolBar
        parkingField.inputAccessoryView = toolBar
        tolFromOfficeField.inputAccessoryView = toolBar
        tolFromClientField.inputAccessoryView = toolBar
        
    }
    
    @IBAction func giveTodayDate(_ sender: UITextField) {
        let uiDate = UIDatePicker()
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .long
        if (dateField.text?.isEmpty)! {
            dateField.text = timeFormatter.string(from: uiDate.date)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customerPickerData.removeAll()
        projectPickerData.removeAll()
        let newData = ["code": "dummy", "name": "-Select One-", "distance": "0"]
        customerPickerData.append(newData)
        projectPickerData.append(newData)
        getClientLists()
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
    
    func donePicker (){
//        let datePicker = UIDatePicker()
//        let timeFormatter = DateFormatter()
//        timeFormatter.dateStyle = .long
//        dateField.text = timeFormatter.string(from: datePicker.date)
        
        activityField.resignFirstResponder()
        projectListField.resignFirstResponder()
        dateField.resignFirstResponder()
    }
    
    func createNewVoucherRowMileage(voucher: [String:String]) {
        print(voucher)
        self.voucherTaxiArray.append(voucher)
        self.myTableView.reloadData()
    }
    
    @IBAction func activityDidEnd(_ sender: UITextField) {
        if (sender.text?.contains("Office"))!{
            projectListField.backgroundColor = disableColor
            projectListField.isUserInteractionEnabled = false
            projectListField.text = ""
            
            otherProjectField.backgroundColor = disableColor
            otherProjectField.isUserInteractionEnabled = false
            
            tolSwitch.setOn(false, animated: true)
            tolContainerHeight.constant = 0
            tolSwitch.isEnabled = false
            
            taxiSwitch.setOn(false, animated: true)
            taxiContainer.alpha = 0
            taxiContainerHeight.constant = 0
            taxiSwitch.isEnabled = false
        } else {
            if (sender.text?.contains("Sales / Pre-sales"))! {
                usePickerData.removeAll()
                usePickerData = customerPickerData
            } else {
                usePickerData.removeAll()
                usePickerData = projectPickerData
            }
            
            projectListField.backgroundColor = UIColor.clear
            projectListField.isUserInteractionEnabled = true
            
            otherProjectField.backgroundColor = UIColor.clear
            otherProjectField.isUserInteractionEnabled = true
            
            tolSwitch.isEnabled = true
            
            taxiSwitch.isEnabled  = true
        }
    }
    
    @IBAction func mealSwitched(_ sender: UISwitch) {
        print(sender.isOn)
        if (sender.isOn) {
            mealPriceHeight.constant = 30
            childViewHeight.constant = childViewHeight.constant + 30
        } else {
            mealPriceHeight.constant = 0
            childViewHeight.constant = childViewHeight.constant - 30
        }
    }
    
    @IBAction func parkingSwitched(_ sender: UISwitch) {
        if (sender.isOn) {
            parkingPriceHeight.constant = 30
            childViewHeight.constant = childViewHeight.constant + 30
        } else {
            parkingPriceHeight.constant = 0
            childViewHeight.constant = childViewHeight.constant - 30
        }
    }
    
    @IBAction func tolSwitched(_ sender: UISwitch) {
        if (sender.isOn) {
            tolContainerHeight.constant = 66
            tolContainer.alpha = 1
            childViewHeight.constant = childViewHeight.constant + 66
        } else {
            tolContainerHeight.constant = 0
            tolContainer.alpha = 0
            childViewHeight.constant = childViewHeight.constant - 66
        }
    }
    
    @IBAction func taxiSwitched(_ sender: UISwitch) {
        if (sender.isOn) {
            taxiContainer.alpha = 1
            addTaxiButton.isEnabled = true
            
//            taxiVoucherTableHeight.constant = 100
            taxiVoucherTable.alpha = 1
//            childViewHeight.constant = childViewHeight.constant + 100
        } else {
            self.voucherTaxiArray.removeAll()
            taxiContainer.alpha = 0
            addTaxiButton.isEnabled = true
//            taxiContainerHeight.constant = 0
//            childViewHeight.constant = childViewHeight.constant - 33
            
//            taxiVoucherTableHeight.constant = 0
            taxiVoucherTable.alpha = 0
//            childViewHeight.constant = childViewHeight.constant - 100
        }
    }
    
    @IBAction func personalSwitched(_ sender: UISwitch) {
        if (sender.isOn) {
            distanceField.alpha = 1
            distanceLabel.alpha = 1
            if(activityField.text?.contains("Office"))! {
                if (tolSwitch.isOn){
                    childViewHeight.constant = childViewHeight.constant - 66
                }
                tolSwitch.setOn(false, animated: true)
                tolContainerHeight.constant = 0
                tolContainer.alpha = 0
                tolSwitch.isEnabled = false
            } else {
                if(!tolSwitch.isOn){
                    childViewHeight.constant = childViewHeight.constant + 66
                }
                tolSwitch.setOn(true, animated: true)
                tolContainerHeight.constant = 66
                tolContainer.alpha = 1
                tolSwitch.isEnabled = true
                
            }
            if(!parkingSwitch.isOn){
                childViewHeight.constant = childViewHeight.constant + 30
            }
            parkingSwitch.setOn(true, animated: true)
            parkingPriceHeight.constant = 30
            parkingSwitch.isEnabled = true
        } else {
            distanceField.alpha = 0
            distanceLabel.alpha = 0
            if(parkingSwitch.isOn){
                childViewHeight.constant = childViewHeight.constant - 30
            }
            if(tolSwitch.isOn){
                childViewHeight.constant = childViewHeight.constant - 66
            }
            parkingSwitch.setOn(false, animated: true)
            tolSwitch.setOn(false, animated: true)
            parkingPriceHeight.constant = 0
            tolContainerHeight.constant = 0
            parkingSwitch.isEnabled = false
            tolSwitch.isEnabled = false
            tolContainer.alpha = 0
        }
    }
    
    @IBAction func projectEndEdit(_ sender: UITextField) {
        if(sender.text?.contains("Other"))!{
            otherProjectFieldHeight.constant = 30
            childViewHeight.constant = childViewHeight.constant + 30
        } else {
            otherProjectFieldHeight.constant = 0
            childViewHeight.constant = childViewHeight.constant - 30
        }
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        activityField.resignFirstResponder()
        projectListField.resignFirstResponder()
        otherProjectField.resignFirstResponder()
        mealFIeld.resignFirstResponder()
        parkingField.resignFirstResponder()
        tolFromOfficeField.resignFirstResponder()
        tolFromClientField.resignFirstResponder()
        distanceField.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
            projectListField.text = usePickerData[row]["name"]
            distanceField.text = usePickerData[row]["distance"]
            hiddenProjectCode.text = usePickerData[row]["code"]
        }
        
    }
    @IBAction func addTaxiVoucher(_ sender: UIButton) {
        let nextViewController = storyboard?.instantiateViewController(withIdentifier: "addNewVoucherMileage") as! VoucherAddNewMileageViewController
        nextViewController.myProtocol = self
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func showDate(_ sender: UITextField) {
        let datePicker:UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MileageViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MileageViewController.donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        sender.inputView = datePicker
        sender.inputAccessoryView = toolBar
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: UIControlEvents.valueChanged)
    }
    
    func handleDatePicker (sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .long
        dateField.text = timeFormatter.string(from: sender.date)
    }
    
    @IBAction func submitMileage(_ sender: UIBarButtonItem) {
        var taxies = Dictionary<String,AnyObject>()
        taxies["taxies"] = self.voucherTaxiArray as AnyObject
        
        var projectTyped = ""
        if (projectListField.text == "Other") {
            projectTyped = otherProjectField.text!
        } else {
            projectTyped = projectListField.text!
        }
        
        let myNewArray = [
            "mileage":[
                "name": SomethingAwesome.usercode,
                "date": dateField.text ?? "Empty" as String,
                "activity": activityField.text!,
                "project": projectTyped,
                "project_code": hiddenProjectCode.text ?? "Empty" as String,
                "project_distance": distanceField.text ?? "Empty" as String,
                "mileage_list":[
                    "meal": mealFIeld.text!,
                    "parking": parkingField.text!,
                    "tol_office": tolFromOfficeField.text!,
                    "tol_client": tolFromClientField.text!,
                    "taxies": self.voucherTaxiArray
                ]
            ]
        ]
        dbProcess(data: myNewArray)
    }
    
    func dbProcess(data:[String:Dictionary<String, Any>]) {
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
            
            let taxi_table = Table("dummy_taxi_devs")
            let voucher_id = Expression<Int64>("id")
            let taxi_voucher = Expression<String>("voucher_id")
            let taxi_from = Expression<String>("taxi_from")
            let taxi_to = Expression<String>("taxi_to")
            let taxi_amount = Expression<String>("taxi_amount")
            let taxi_time = Expression<String>("taxi_time")
            let trx_id = Expression<String>("trx_id")
            
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
            
            try mileageDb.run(taxi_table.create(ifNotExists:true) { t in
                t.column(voucher_id, primaryKey: true)
                t.column(taxi_voucher)
                t.column(taxi_from)
                t.column(taxi_to)
                t.column(taxi_amount)
                t.column(taxi_time)
                t.column(trx_id)
            })
            
            let mileageData = data["mileage"]?["mileage_list"] as? [String:AnyObject]
            let taxiesData = mileageData?["taxies"] as! [Dictionary<String,String>]

            let insert =
                users.insert(name <- data["mileage"]?["name"] as! String,
                             new_date <- data["mileage"]?["date"] as! String,
                             activity <- data["mileage"]?["activity"] as! String,
                             project <- data["mileage"]?["project"] as! String,
                             project_code <- data["mileage"]?["project_code"] as! String,
                             project_distance <- data["mileage"]?["project_distance"] as! String,
                             meal <- mileageData?["meal"] as! String,
                             parking <- mileageData?["parking"] as! String,
                             toll_office <- mileageData?["tol_office"] as! String,
                             toll_client <- mileageData?["tol_client"] as! String,
                             tag <- "mileage",
                             leave_from <- "",
                             leave_to <- "",
                             leave_project <- "",
                             leave_stats <- "")
            let row_id = try mileageDb.run(insert)
            print(row_id)
            
            for i in 0 ..< taxiesData.count {
                let taxiInsert = taxi_table.insert(taxi_voucher <- taxiesData[i]["voucher_number"]!,
                                                   taxi_amount <- taxiesData[i]["price"]!,
                                                   taxi_from <- taxiesData[i]["from"]!,
                                                   taxi_to <- taxiesData[i]["to"]!,
                                                   taxi_time <- taxiesData[i]["time"]!,
                                                   trx_id <- String(row_id))
                try mileageDb.run(taxiInsert)
            }
            
            saveSuccess()
            
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(voucherTaxiArray.count == 0) {
            return self.items.count
        } else {
            return self.voucherTaxiArray.count;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        print(voucherTaxiArray.count)
        if (voucherTaxiArray.count > 0) {
            cell.textLabel?.text = self.voucherTaxiArray[indexPath.row]["voucher_number"]!
            cell.detailTextLabel?.text = self.voucherTaxiArray[indexPath.row]["price"]!
        } else {
            cell.textLabel?.text = self.items[indexPath.row]
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    func saveSuccess () {
        let alertController = UIAlertController(title: "Success", message: "Your request has been saved", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            self.distanceField.text = ""
            self.dateField.text = ""
            self.mealFIeld.text = ""
            self.parkingField.text = ""
            self.activityField.text = ""
            self.projectListField.text = ""
            self.otherProjectField.text = ""
            self.tolFromClientField.text = ""
            self.tolFromOfficeField.text = ""
            self.voucherTaxiArray.removeAll()
            self.myTableView.reloadData()
            
        }
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
