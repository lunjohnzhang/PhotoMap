//
//  ViewController.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/11/19.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import UIKit

class ChooseViewController: UIViewController {

    @IBOutlet weak var backImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewWillAppear(_ animated: Bool) {
        // UIApplication.shared.statusBarStyle = .lightContent
        backImage.image = Helper.helper.getBackground()
    }
    

}

