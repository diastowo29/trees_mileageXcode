//
//  LoadingViewController.swift
//  MyTrees
//
//  Created by Eldien Hasmanto on 6/12/17.
//  Copyright © 2017 Eldien Hasmanto. All rights reserved.
//

import UIKit
import SQLite

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if (getCredit() > 0) {
            getUserDetail()
            performSegue(withIdentifier: "loginSuccess", sender: self)
        } else {
            performSegue(withIdentifier: "loginFail", sender: self)
        }
    }
    
    func getCredit () -> Int {
        var count = 0
        do {
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
            count = try mileageDb.scalar(users.count)
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }
        return count
    }
    
    func getUserDetail () {
        do {
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
            
            if let user = try mileageDb.pluck(users) {
                SomethingAwesome.username = user[emp_Name]
                SomethingAwesome.usercode = user[emp_Number]
                SomethingAwesome.token = user[emp_token]
            }
            deleteLists()
            
        } catch {
            print("SQLite Error")
            print(error.localizedDescription)
        }
    }
    
    func getLists () {
        
        let url = URL(string: "https://trees-web-service.herokuapp.com/api/v1/lists")!
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
                print("finish")
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func saveList (listCode: String, listName: String, listDistance: String, listType: String) {
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

}
