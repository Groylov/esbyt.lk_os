//
//  TestViewController.swift
//  mobile
//
//  Created by Groylov on 14/02/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var sc: UIScrollView!
    
    @IBOutlet weak var sssss: UIView!
    
    @IBOutlet weak var hghgf: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        print(scrollView.contentOffset.y)

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        sssss.alpha = 1
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        sssss.alpha = 1
    }
    
  
    


}
