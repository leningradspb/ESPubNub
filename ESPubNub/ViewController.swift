//
//  ViewController.swift
//  ESPubNub
//
//  Created by Eduard Sinyakov on 03.06.2021.
//

import UIKit
import PubNub

class ViewController: UIViewController {
    
    private var pubNub: PubNub!
//    {
//        var config = PubNubConfiguration(publishKey: "pub-c-f8a06059-fb89-4b42-9e96-63f6211354a1", subscribeKey: "sub-c-3293f7fe-c44b-11eb-9292-4e51a9db8267")
//        config.uuid = "3dcde054-17ec-48ba-88f9-93fca230ca8a"
//        let pubNub = PubNub(configuration: config)
//        return pubNub
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var config = PubNubConfiguration(publishKey: "pub-c-f8a06059-fb89-4b42-9e96-63f6211354a1", subscribeKey: "sub-c-3293f7fe-c44b-11eb-9292-4e51a9db8267")
        config.uuid = "3dcde054-17ec-48ba-88f9-93fca230ca8a"
        pubNub = PubNub(configuration: config)
        
        pubNub.fetchMessageHistory(for: ["my_channel"]) { result in
            print(result)
        }
        
        setupMessageListener()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.sendMessage()
//        }
//        setupPubNubConfig()
    }
    
//    private func setupPubNubConfig() {
//        var config = PubNubConfiguration(publishKey: "pub-c-fdd20a63-fd16-4a8f-930d-6cb72eb6d916", subscribeKey: "sub-c-60714650-c300-11eb-8a3a-220055b20f11")
//        config.uuid = "3dcde054-17ec-48ba-88f9-93fca230ca8a"
//        let pubNub = PubNub(configuration: config)
//    }
    
    private func setupMessageListener() {
        // Create a new listener instance
        let listener = SubscriptionListener(queue: .main)
        listener.didReceiveMessage = { message in
            print(message)
        }
        // Add listener event callbacks
        listener.didReceiveSubscription = { event in
          switch event {
          case let .messageReceived(message):
            print("Message Received: \(message) Publisher: \(message.publisher ?? "defaultUUID")")
          case let .connectionStatusChanged(status):
            print("Status Received: \(status)")
          case let .presenceChanged(presence):
            print("Presence Received: \(presence)")
          case let .subscribeError(error):
            print("Subscription Error \(error)")
          default:
            break
          }
        }

        // Start receiving subscription events
        pubNub.add(listener)
    }
    
    private func sendMessage() {
        
        pubNub.publish(channel: "my_channel", message: ["text": "Hello World!"] ){ result in
            switch result {
            case let .success(response):
                print("succeeded: \(response.description)")
                
            case let .failure(error):
                print("failed: \(error.localizedDescription)")
            }
        }
    }

}

