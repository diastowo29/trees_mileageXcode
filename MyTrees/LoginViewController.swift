//
//  LoginViewController.swift
//  MyTrees
//
//  Created by Eldien Hasmanto on 6/12/17.
//  Copyright © 2017 Eldien Hasmanto. All rights reserved.
//

import UIKit
import SQLite

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var phoneFIeld: UITextField!
//    let alertController = UIAlertController(title: "Loading", message: "Please Wait", preferredStyle: .alert)

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goLogin(_ sender: UIButton) {
        loadingView.alpha = 1
        loadingIndicator.startAnimating()
        phoneFIeld.resignFirstResponder()
        checkCredit(postCompleted: self.checkLogin(succeed:msg:data:))
    }
    
    func checkLogin(succeed: Bool, msg: String, data: [String:Any]){
        if (succeed){
            loadingView.alpha = 0
            loadingIndicator.stopAnimating()
            let user = data["user"] as? [String:String]
            self.saveCredit(cellNo: user?["cell_no"] as! String, empName: user?["employee_name"] as! String, empNumber: user?["employee_number"] as! String, token: data["access_token"] as! String)
            self.deleteLists()
        } else {
            errorNotFound()
        }
    }
    
    func checkCredit (postCompleted : @escaping (_ succeeded: Bool, _ msg: String, _ data: [String:Any]) -> ()) {
//        present(alertController, animated: true, completion: nil)
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        let parameters = ["cell_no": "\(phoneFIeld.text!)"] as Dictionary<String, String>
        
        //create the url with URL
        let url = URL(string: SomethingAwesome.urlLogin)!
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
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
                    if((json["status"] as! String) == "error") {
                        print(json)
                        postCompleted(false, "Error", json)
                    } else {
                        postCompleted(true, "Success", json)
                    }
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func errorNotFound () {
        let errorAlertController = UIAlertController(title: "Error", message: "Employee not found", preferredStyle: .alert)
        let errorAlertAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            self.loadingView.alpha = 0
            self.loadingIndicator.stopAnimating()
        }
        errorAlertController.addAction(errorAlertAction)
        present(errorAlertController, animated: true, completion: nil)
    }
    
    func getLists () {
        print("getLists")
        let url = URL(string: SomethingAwesome.urlClientList)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    let customers = json["customers"] as! [Dictionary<String,Any>]
                    let projects = json["projects"] as! [Dictionary<String,Any>]
                    
                    if (customers.count > 0) {
                        for i in 0 ..< customers.count {
                            self.saveList(listCode: customers[i]["customer_code"] as! String, listName: customers[i]["customer_name"] as! String, listDistance: (String(customers[i]["total_distance"] as! Int)), listType: "customers")
                        }
                    }
                    if (projects.count > 0) {
                        for i in 0 ..< projects.count {
                            self.saveList(listCode: projects[i]["project_number"] as! String, listName: projects[i]["project_name"] as! String, listDistance: (String(projects[i]["total_distance"] as! Int)), listType: "projects")
                        }
                    }
                }
                self.performSegue(withIdentifier: "loginSuccess", sender: self)
                
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func testingFunction () {
        print("testing")
        
    }
    
    func saveList (listCode: String, listName: String, listDistance: String, listType: String) {
        print("saveList")
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
            let insert =
                users.insert(list_code <- listCode,
                             list_name <- listName,
                             list_distance <- listDistance,
                             list_type <- listType)
            _ = try mileageDb.run(insert)
            
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }
    }
    
    func deleteLists () {
        print("deleteLists")
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
            try mileageDb.run(users.delete())
            getLists()
            
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }
    }

    
    func saveCredit (cellNo: String, empName: String, empNumber: String, token: String) {
        do {
            print("saveCredit")
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let mileageDb = try Connection("\(path)/db.sqlite3")
            let users = Table("dummy_users")
            let id = Expression<Int64>("id")
            let emp_Name = Expression<String>("employee_name")
            let emp_Phone = Expression<String>("employee_phone")
            let emp_Number = Expression<String>("employee_number")
            let emp_token = Expression<String>("token")
            
            try mileageDb.run(users.create(ifNotExists:true) { t in
                t.column(id, primaryKey: true)
                t.column(emp_Name)
                t.column(emp_Phone)
                t.column(emp_Number)
                t.column(emp_token)
            })
            
            let insert =
                users.insert(emp_Name <- empName,
                             emp_Number <- empNumber,
                             emp_Phone <- cellNo,
                             emp_token <- token)
            _ = try mileageDb.run(insert)
            
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }
    }
}
