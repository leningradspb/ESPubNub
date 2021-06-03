
import UIKit
import PubNub

class ConversationsVC: BaseVC {
    private let tableView = UITableView()
    private var conversations: [ConversationData.Conversation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        observeConversations()
        loadConversations()
        setupMessageListener()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.sendMessage()
//                }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Chats"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupTableView() {
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func observeConversations() {
      
    }
    
    private func loadConversations() {
        var chatIDs: [String] = []
        pubNub.fetchMemberships(uuid: "3dcde054-17ec-48ba-88f9-93fca230ca8a") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                print("succeeded: \(response)")
                response.memberships.forEach {
                    chatIDs.append($0.channelMetadataId)
                }
                self.pubNub.subscribe(to: chatIDs)
                self.loadLastMessageBy(chatIDs: chatIDs)
                
            case let .failure(error):
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupMessageListener() {
        // Create a new listener instance
        let listener = SubscriptionListener(queue: .main)
//        listener.didReceiveMessage = { message in
//            print(message)
//        }
        // Add listener event callbacks
        listener.didReceiveSubscription = { [weak self] event in
            guard let self = self else { return }
          switch event {
          case let .messageReceived(message):
            print("Message Received: \(message) Publisher: \(message.publisher ?? "defaultUUID")")
            let timestamp = message.payload[rawValue: "timestamp"] as? String
            let timestampDouble = Double(timestamp ?? "0")
            let newMessage = Message(fromID: message.payload[rawValue: "fromID"] as? String, message: message.payload[rawValue: "text"] as? String, toID: message.payload[rawValue: "toID"] as? String, timestamp: timestampDouble, channel: message.channel)
            if self.conversations.contains(where: { $0.lastMessage?.channel == message.channel }) {
                if let index = self.conversations.firstIndex(where: { $0.lastMessage?.channel == message.channel }) {
                    self.conversations[index].lastMessage = newMessage
                }
            } else {
                self.conversations.append(ConversationData.Conversation(lastMessage: newMessage))
            }
            self.tableView.reloadData()
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
    
    private func loadLastMessageBy(chatIDs: [String]) {
        pubNub.fetchMessageHistory(for: chatIDs, includeActions: false, includeMeta: false, includeUUID: false, includeMessageType: false, page: PubNubBoundedPageBase(start: nil, end: nil, limit: 1) , custom: .init()) { [weak self] result in
            guard let self = self else { return }
            print(result)
            result.map {
                $0.messagesByChannel.values.forEach {
                    
                    $0.forEach {
                        print($0.payload)
                        
                        let fromID = $0.payload[rawValue: "fromID"] as? String
                        let toID = $0.payload[rawValue: "toID"] as? String
                        let timestamp = $0.payload[rawValue: "timestamp"] as? String
                        let timestampDouble = Double(timestamp ?? "0")
                        let message = $0.payload[rawValue: "text"] as? String
                        let channel = $0.channel
                        self.conversations.append(ConversationData.Conversation.init(lastMessage: Message(fromID: fromID, message: message, toID: toID, timestamp: timestampDouble, channel: channel)))
                    }
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func showChat(by index: Int) {
        let conversation = conversations[index]

//        let pairID = conversation.user?.userID ?? ""

        let model = ChatVC.ChatInitModel(partnerID: "someID", channelID: conversation.lastMessage?.channel ?? "")
        let vc = ChatVC(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //TODO; delete
    private func sendMessage() {
        let timestamp: Double = Date().timeIntervalSince1970
        let timestampString: String = String(format: "%f", timestamp)
        pubNub.publish(channel: "channel_2", message: ["text": "channel 2 message new", "timestamp": timestampString, "fromID": myID, "toID": "someID"] ) { result in
            switch result {
            case let .success(response):
                print("succeeded: \(response.description)")
                
            case let .failure(error):
                print("failed: \(error.localizedDescription)")
            }
        }
    }
}

extension ConversationsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.identifier, for: indexPath) as! ConversationCell
        
        if indexPath.row < conversations.count {
            let model = conversations[indexPath.row]
            cell.updateConversationCell(with: model)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showChat(by: indexPath.row)
    }
}

