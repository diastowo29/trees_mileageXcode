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
        let datePicker:UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.time
        datePicker.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneHandler))
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        timeFIeld.inputView = datePicker
        timeFIeld.inputAccessoryView = toolBar
        datePicker.addTarget(self, action: #selector(handleTimePicker), for: UIControlEvents.valueChanged)
    }
    
    @IBAction func tapGestureTapped(_ sender: UITapGestureRecognizer) {
        timeFIeld.resignFirstResponder()
        voucherNumberField.resignFirstResponder()
        fromField.resignFirstResponder()
        toField.resignFirstResponder()
        priceField.resignFirstResponder()
    }
    
    func doneHandler () {
        timeFIeld.resignFirstResponder()
    }
    
    func handleTimePicker (sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .medium
        timeFormatter.dateFormat = "HHmm"
        timeFormatter.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        timeFormatter.dateStyle = .none
        timeFIeld.text = timeFormatter.string(from: sender.date)
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
