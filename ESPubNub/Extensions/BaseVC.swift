//
//  BaseVC.swift
//  ESPubNub
//
//  Created by Eduard Sinyakov on 03.06.2021.
//

import UIKit
import PubNub

class BaseVC: UIViewController {
    var pubNub: PubNub!
    
    var myID: String {
        "3dcde054-17ec-48ba-88f9-93fca230ca8a"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPubNubConfig()
    }
    
    private func setupPubNubConfig() {
        var config = PubNubConfiguration(publishKey: "pub-c-f8a06059-fb89-4b42-9e96-63f6211354a1", subscribeKey: "sub-c-3293f7fe-c44b-11eb-9292-4e51a9db8267")
        config.uuid = "3dcde054-17ec-48ba-88f9-93fca230ca8a"
        pubNub = PubNub(configuration: config)
    }
}
