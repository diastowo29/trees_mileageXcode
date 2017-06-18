//
//  VoucherEditViewController.swift
//  MyTrees
//
//  Created by Eldien Hasmanto on 6/7/17.
//  Copyright © 2017 Eldien Hasmanto. All rights reserved.
//

import UIKit
import SQLite

protocol deleteProtocol {
    func deleteRowWithId (value: String)
    func deleteRowat (value: String)
}

class VoucherEditViewController: UIViewController {
    
    var voucherTaxies = Dictionary<String, String>()
    var voucherID = ""
    var myDeleteProtocol: deleteProtocol?
    
    @IBOutlet weak var voucherNumberFIeld: UITextField!
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var timeField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        print(voucherTaxies)
        voucherNumberFIeld.text = voucherTaxies["voucher_number"]! 
        fromField.text = voucherTaxies["from"]!
        toField.text = voucherTaxies["to"]!
        priceField.text = voucherTaxies["price"]!
        timeField.text = voucherTaxies["time"]!
        
        voucherID = voucherTaxies["row"]!
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goDeleteVoucher(_ sender: Any) {
        myDeleteProtocol?.deleteRowWithId(value: self.voucherTaxies["voucher_id"]!)
        myDeleteProtocol?.deleteRowat(value: voucherID)
        self.navigationController?.popViewController(animated: true)
    }
    
    

}
