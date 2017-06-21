//
//  VoucherAddNewViewController.swift
//  MyTrees
//
//  Created by Eldien Hasmanto on 6/7/17.
//  Copyright © 2017 Eldien Hasmanto. All rights reserved.
//

import UIKit
import SQLite

protocol createNewVoucher {
    func createNewVoucherRow(voucher: [String:String])
}

class VoucherAddNewViewController: UIViewController {
    
    @IBOutlet weak var voucherNumberField: UITextField!
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var timeFIeld: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    var trx_id:String = ""
    var myProtocol:createNewVoucher?

    override func viewDidLoad() {
        super.viewDidLoad()
        print(trx_id)
    }
    
    @IBAction func goSaveVoucher(_ sender: Any) {
        let voucher_array = [
            "voucher_number": voucherNumberField.text!,
            "price": priceField.text!,
            "from": fromField.text!,
            "to": toField.text!,
            "time": timeFIeld.text!,
            "trx_id": trx_id
        ]
        myProtocol?.createNewVoucherRow(voucher: voucher_array )
        self.navigationController?.popViewController(animated: true)
        
    }
}
