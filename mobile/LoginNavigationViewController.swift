//
//  LoginNavigationViewController.swift
//  mobile
//
//  Created by Groylov on 07/06/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class LoginNavigationViewController: UINavigationController {

    var userListPostFunction: ((String,String,BackOfficeMobileReturn) -> Void)?
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
