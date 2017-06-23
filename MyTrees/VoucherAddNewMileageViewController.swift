//
//  VoucherAddNewMileageViewController.swift
//  MyTrees
//
//  Created by Eldien Hasmanto on 6/19/17.
//  Copyright © 2017 Eldien Hasmanto. All rights reserved.
//

import UIKit

protocol createNewVoucherMileage {
    func createNewVoucherRowMileage(voucher: [String:String])
}

class VoucherAddNewMileageViewController: UIViewController {
    
    @IBOutlet weak var voucherNumberField: UITextField!
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var timeFIeld: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    var taxiPrice: Int { return priceField.string.digits.integer }
    
    var trx_id:String = ""
    var myProtocol:createNewVoucherMileage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        priceField.textAlignment = .right
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
    
    @IBAction func priceChanged(_ sender: UITextField) {
        sender.text = Formatter.decimal.string(from: taxiPrice as NSNumber)
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
            "price": String(describing: taxiPrice),
            "from": fromField.text!,
            "to": toField.text!,
            "time": timeFIeld.text!
        ]
        myProtocol?.createNewVoucherRowMileage(voucher: voucher_array )
        self.navigationController?.popViewController(animated: true)
    }
}
