//
//  MyClaimViewController.swift
//  MyTrees
//
//  Created by Eldien Hasmanto on 5/17/17.
//  Copyright © 2017 Eldien Hasmanto. All rights reserved.
//

import UIKit
import SQLite

class MyClaimViewController: BaseViewController, UITabBarDelegate, UITableViewDelegate,
 UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myTabBar: UITabBar!
    @IBOutlet weak var savedTabBar: UITabBarItem!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    var selectRow = [String]()
    var successLog = [Dictionary<String,String>]()
    var errorLog = [String]()
    var trx_array = [Dictionary<String, Dictionary<String,Any>>()]
    
    override func viewDidLoad() {
        self.trx_array.removeAll()
        super.viewDidLoad()
        self.addSlideMenuButton()
        savedTabBar.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        deleteLists()
//        getLists()
        getList()
        tableView.reloadData()
        loadingView.alpha = 0
        loadingIndicator.stopAnimating()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            getList()
            tableView.reloadData()
            break
        case 1:
            getList()
            tableView.reloadData()
            break
        default:
            getList()
            tableView.reloadData()
            break
        }
    }
    
    @IBAction func doRefresh(_ sender: UIBarButtonItem) {
        
    }
    
    func getList () {
        trx_array.removeAll()
        var all_voucher_array = [Dictionary<String, String>()]
        all_voucher_array.removeAll()
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
            for user in try mileageDb.prepare(users.filter(name == SomethingAwesome.usercode)) {
                var taxiCount = 0
                for taxi in try mileageDb.prepare(taxi_table.filter(trx_id == String(user[id]))){
                    let voucher_array = [
                        "voucher_id": String(taxi[voucher_id]),
                        "voucher_number": taxi[taxi_voucher],
                        "price": taxi[taxi_amount],
                        "from": taxi[taxi_from],
                        "to": taxi[taxi_to],
                        "time": taxi[taxi_time],
                        "row": String(taxiCount)
                    ]
                    taxiCount += 1
                    all_voucher_array.append(voucher_array)
                }
                let new_trx_array = [
                    "mileage":[
                        "id": user[id],
                        "name": user[name],
                        "date": user[new_date],
                        "activity": user[activity],
                        "project": user[project],
                        "project_code": user[project_code],
                        "project_distance": user[project_distance],
                        "mileage_list":[
                            "meal": user[meal],
                            "parking": user[parking],
                            "tol_office": user[toll_office],
                            "tol_client": user[toll_client],
                            "taxies": all_voucher_array
                        ],
                        "tag": user[tag],
                        "leave_from": user[leave_from],
                        "leave_to": user[leave_to],
                        "leave_project": user[leave_project],
                        "leave_stats": user[leave_stats]
                    ]
                ]
                trx_array.append(new_trx_array)
            }
            
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "testingSegue") {
            if let destinaton = segue.destination as? EditingViewController {
                destinaton.trx = self.trx_array[(sender as? Int)!]
            }
        } else {
            if let destination = segue.destination as? EditingAbsenceViewController {
                destination.trx = self.trx_array[(sender as? Int)!]
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // create new branch
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            if (String(describing:self.trx_array[indexPath.row]["mileage"]?["tag"]).contains("mileage")) {
                self.performSegue(withIdentifier: "testingSegue", sender: indexPath.row)
            } else {
                self.performSegue(withIdentifier: "testingSegueAbsence", sender: indexPath.row)
            }
        }
        editAction.backgroundColor = .gray
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            self.trx_array.remove(at: indexPath.row)
            tableView.reloadData()
        }
        deleteAction.backgroundColor = .red
        
        return [editAction,deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            let row = selectRow.index(of: String(indexPath.row))
            selectRow.remove(at: row!)
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            selectRow.append(String(indexPath.row))        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trx_array.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trxCell", for: indexPath)
        if (trx_array.count > 0) {
            cell.textLabel?.text = self.trx_array[indexPath.row]["mileage"]?["date"] as? String
            cell.detailTextLabel?.text = self.trx_array[indexPath.row]["mileage"]?["project"] as? String
            if (String(describing: trx_array[indexPath.row]["mileage"]?["tag"]).contains("mileage")) {
                cell.imageView?.image = UIImage(named: "parking")
            } else {
                cell.imageView?.image = UIImage(named: "calendar")
            }
        }
        return cell
    }
    
    @IBAction func submitClaim(_ sender: Any) {
        loadingView.alpha = 1
        loadingIndicator.startAnimating()
        var isLeave = false
        var isMileage = false
        var leaveCount = 0
        var mileageCount = 0
        var curr_leaveCount = 0
        var curr_mileageCount = 0
        var claiml = [Dictionary<String, Any>]()
        var claim = [Dictionary<String, Any>]()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateResult = formatter.string(from: date)
        claim.removeAll()
        for trxxx in 0 ..< selectRow.count {
            let indexRow = Int(selectRow[trxxx])
            print(trx_array[indexRow!])
            if ((trx_array[indexRow!]["mileage"]?["tag"] as! String) == "leave") {
                isLeave = true
                leaveCount += 1
            } else {
                isMileage = true
                mileageCount += 1
            }
        }
        for trxx in 0 ..< selectRow.count {
            let indexRow = Int(selectRow[trxx])
            if ((trx_array[indexRow!]["mileage"]?["tag"] as! String) == "leave") {
                curr_leaveCount += 1
                var absenceStats = ""
                if (trx_array[indexRow!]["mileage"]?["project_code"] as! String).contains("Cuti") {
                    absenceStats = "1"
                } else {
                    absenceStats = "2"
                }
                let absenceDetail = ["date_from": trx_array[indexRow!]["mileage"]?["date"] as! String,
                               "date_to": trx_array[indexRow!]["mileage"]?["leave_to"] as! String,
                               "project_number": trx_array[indexRow!]["mileage"]?["project_code"] as! String,
                               "activity_status": absenceStats,
                               "created_by": SomethingAwesome.username,
//                               "creation_date": dateResult
                    ] as Dictionary<String,String>
                claiml.append(absenceDetail)
                if (curr_leaveCount == leaveCount) {
                    print("postMileage onLeave")
                    let absence = ["absences": claiml] as Dictionary<String, Any>
                    postMileage(parametersData: absence, apiUrl: SomethingAwesome.urlAbsenceMany, activity: "leave", countLeave: leaveCount, countMileage: mileageCount, thereisLeave: isLeave, thereisMileage: isMileage)
                }
            } else {
                curr_mileageCount += 1
//                print(trx_array[indexRow!])
                let mileageList = trx_array[indexRow!]["mileage"]?["mileage_list"] as! Dictionary<String, Any>
                let taxiesCount = mileageList["taxies"] as! [Dictionary<String,String>]
                var taxies = [Dictionary<String,String>]()
                if (taxiesCount.count) > 0 {
                    taxies.removeAll()
                    for i in 0 ..< taxiesCount.count {
                        let taxiDetail = ["taxi_from": taxiesCount[i]["from"],
                                          "taxi_to": taxiesCount[i]["to"],
                                          "taxi_time": taxiesCount[i]["time"],
                                          "taxi_voucher_no": taxiesCount[i]["voucher_number"],
                                          "taxi_amount": taxiesCount[i]["price"]] as! Dictionary<String,String>
                        taxies.append(taxiDetail)
                    }
                }
                let claimDetail = ["claim_date":trx_array[indexRow!]["mileage"]?["date"] as! String,
                                   "activity_code": trx_array[indexRow!]["mileage"]?["activity"] as! String,
                                   "toll_from": mileageList["tol_office"] as! String,
                                   "toll_to": mileageList["tol_client"] as! String,
                                   "mileage": trx_array[indexRow!]["mileage"]?["project_distance"] as! String,
                                   "parking": mileageList["parking"] as! String,
                                   "client_code": trx_array[indexRow!]["mileage"]?["project_code"] as! String,
                                   "meal": mileageList["meal"] as! String,
                                   "created_by": SomethingAwesome.username,
//                                   "creation_date": dateResult,
                                   "claim_details": taxies] as Dictionary<String,Any>
                claim.append(claimDetail)
                if (curr_mileageCount == mileageCount) {
                    print("postMileage onMileage")
                    let mainClaim = ["claim_headers": claim] as Dictionary<String,Any>
                    postMileage(parametersData: mainClaim, apiUrl: SomethingAwesome.urlMileageMany, activity: "mileage", countLeave: leaveCount, countMileage: mileageCount, thereisLeave: isLeave, thereisMileage: isMileage)
                }
            }
        }
    }
    
    func postMileage (parametersData: Dictionary<String, Any>, apiUrl: String, activity: String, countLeave: Int, countMileage: Int, thereisLeave: Bool, thereisMileage: Bool) {
        var totalData = 1
        if (thereisLeave && thereisMileage){
            totalData = 2
        }
//        let alertController = UIAlertController(title: "Loading", message: "Please Wait", preferredStyle: .alert)
//        present(alertController, animated: true, completion: nil)
        
        let url = URL(string: apiUrl)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parametersData, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(SomethingAwesome.token)", forHTTPHeaderField: "Authorization")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if ((json["status"] as! String) == "error") {
                        print(json)
                        self.submitSuccess(activity: activity, mark: "error", totalData: totalData)
                    } else {
                        print(json["status_code"])
                        self.submitSuccess(activity: activity, mark: "success", totalData: totalData)
                    }
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        })
        task.resume()
    }
        
    func submitSuccess (activity: String, mark: String, totalData: Int) {
        print("submitSuccess \(activity) , \(mark), \(totalData)")
        let newLog = [mark: activity]
        successLog.append(newLog)
        var errorMessage = ""
        if (mark == "success") {
            for trxx in 0 ..< selectRow.count {
                let indexRow = Int(selectRow[trxx])
                print(trx_array[indexRow!]["mileage"]?["tag"] as! String)
                if (trx_array[indexRow!]["mileage"]?["tag"] as! String == activity) {
                    print(trx_array[indexRow!]["mileage"]?["id"])
                }
            }
        }
        if (successLog.count == totalData) {
            for i in 0 ..< successLog.count {
                if (successLog[i]["error"] != nil) {
                    errorMessage = ", however, your \((successLog[i]["error"])!) request contains an error, please repeat this row"
                }
            }
            let alertController2 = UIAlertController(title: "Well Done", message: "Your request has been submitted\(errorMessage).", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                alertController2.dismiss(animated: true, completion: nil)
                self.loadingView.alpha = 0
                self.loadingIndicator.stopAnimating()
            }
            alertController2.addAction(confirmAction)
            present(alertController2, animated: true, completion: nil)
            successLog.removeAll()
        }
    }
    
    func submitError () {
        let alertController2 = UIAlertController(title: "Error", message: "Your request contains an error. Please check..", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            alertController2.dismiss(animated: true, completion: nil)
        }
        alertController2.addAction(confirmAction)
        present(alertController2, animated: true, completion: nil)
    }
    
}
