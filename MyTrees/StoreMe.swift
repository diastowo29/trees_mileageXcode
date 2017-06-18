//
//  StoreMe.swift
//  MyTrees
//
//  Created by Eldien Hasmanto on 6/13/17.
//  Copyright © 2017 Eldien Hasmanto. All rights reserved.
//

import Foundation

struct SomethingAwesome {
    static var username = ""
    static var usercode = ""
    static var token = ""
    
    static var urlMileage = "https://trees-web-service.herokuapp.com/api/v1/claims/header"
    static var urlMileageMany = "https://trees-web-service.herokuapp.com/api/v1/claims/create_many"
    static var urlTaxi = "https://trees-web-service.herokuapp.com/api/v1/claims/header/TRX_ID/details"
    static var urlBbsence = "https://trees-web-service.herokuapp.com/api/v1/absences"
    static var urlAbsenceMany = "https://trees-web-service.herokuapp.com/api/v1/absences/create_many"
    static var urlClientList = "https://trees-web-service.herokuapp.com/api/v1/lists"
    static var urlLogin = "https://trees-web-service.herokuapp.com/api/v1/login"
}
