//
//  MedicalViewController.swift
//  MyTrees
//
//  Created by Eldien Hasmanto on 5/5/17.
//  Copyright © 2017 Eldien Hasmanto. All rights reserved.
//

import UIKit

class MedicalViewController: BaseViewController {
    var testing = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
    }
    
    @IBAction func goNext(_ sender: Any) {
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print(testing)
    }
    
}
