
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
                self.loadLastMessageBy(chatIDs: chatIDs)
                
            case let .failure(error):
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadLastMessageBy(chatIDs: [String]) {
        pubNub.fetchMessageHistory(for: chatIDs, includeActions: false, includeMeta: false, includeUUID: false, includeMessageType: false, page: PubNubBoundedPageBase(start: nil, end: nil, limit: 1) , custom: .init()) { [weak self] result in
            guard let self = self else { return }
            print(result)
            result.map {
                $0.messagesByChannel.values.forEach {
                    
                    $0.forEach {
                        print($0.payload)
                        
                        let formID = $0.payload[rawValue: "formID"] as? String
                        let toID = $0.payload[rawValue: "toID"] as? String
                        let timestamp = $0.payload[rawValue: "timestamp"] as? String
                        let timestampDouble = Double(timestamp ?? "0")
                        let message = $0.payload[rawValue: "text"] as? String
                        self.conversations.append(ConversationData.Conversation.init(lastMessage: Message(formID: formID, message: message, toID: toID, timestamp: timestampDouble)))
                    }
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func showChat(by index: Int) {
//        let conversation = conversations[index]
//
//        let pairID = conversation.user?.userID ?? ""
//
//        let model = ChatVC.ChatInitModel(partnerID: pairID, autoID: nil, path: nil)
//        let vc = ChatVC(model: model)
//        self.navigationController?.pushViewController(vc, animated: true)
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

