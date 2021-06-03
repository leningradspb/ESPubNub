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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPubNubConfig()
        loadMessages()
        subscribeOnChannel()
        setupMessageListener()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.sendMessage()
//        }
    }
    
    private func setupPubNubConfig() {
        var config = PubNubConfiguration(publishKey: "pub-c-f8a06059-fb89-4b42-9e96-63f6211354a1", subscribeKey: "sub-c-3293f7fe-c44b-11eb-9292-4e51a9db8267")
        config.uuid = "3dcde054-17ec-48ba-88f9-93fca230ca8a"
        pubNub = PubNub(configuration: config)
    }
    
    private func subscribeOnChannel() {
        pubNub.subscribe(to: ["my_channel"])
    }
    
    private func loadMessages() {
        pubNub.fetchMessageHistory(for: ["my_channel"]) { result in
//            print(result)
        }
        
        pubNub.fetchMemberships(uuid: "3dcde054-17ec-48ba-88f9-93fca230ca8a") { (result) in
//            print(result)
        }
        
        pubNub.fetchMessageHistory(for: ["my_channel"], includeActions: false, includeMeta: false, includeUUID: false, includeMessageType: false, page: PubNubBoundedPageBase(start: nil, end: nil, limit: 1) , custom: .init()) { (result) in
            print(result)
        }
        
        
        let newMembership = PubNubMembershipMetadataBase(
            uuidMetadataId: "3dcde054-17ec-48ba-88f9-93fca230ca8a", channelMetadataId: "channel_2"
        )
        
//        pubNub.setMemberships(
//          uuid: newMembership.uuidMetadataId,
//          channels: [newMembership]
//        ) { result in
//          switch result {
//          case let .success(response):
//            print("The channel memberships for the uuid \(response.memberships)")
//            if let nextPage = response.next {
//              print("The next page used for pagination: \(nextPage)")
//            }
//          case let .failure(error):
//            print("Update Memberships request failed with error: \(error.localizedDescription)")
//          }
//        }
        
//        let newMembership = PubNubMembershipMetadataBase(
//          uuidMetadataId: "3dcde054-17ec-48ba-88f9-93fca230ca8a", channelMetadataId: "my_channel"
//        )
//        pubNub.setMemberships(
//            uuid: newMembership.channelMetadataId,
//            channels: [newMembership]
//        ) { result in
//          switch result {
//          case let .success(response):
//            print("The channel memberships for the uuid \(response.memberships)")
//            if let nextPage = response.next {
//              print("The next page used for pagination: \(nextPage)")
//            }
//          case let .failure(error):
//            print("Update Memberships request failed with error: \(error.localizedDescription)")
//          }
//        }

    }
    
    private func setupMessageListener() {
        // Create a new listener instance
        let listener = SubscriptionListener(queue: .main)
//        listener.didReceiveMessage = { message in
//            print(message)
//        }
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
        
        pubNub.publish(channel: "my_channel", message: ["text": "!!!!Hello World!"] ){ result in
            switch result {
            case let .success(response):
                print("succeeded: \(response.description)")
                
            case let .failure(error):
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    deinit {
        pubNub.unsubscribeAll()
    }
}


