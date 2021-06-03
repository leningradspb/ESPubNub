
import UIKit
import PubNub

class ConversationsVC: BaseVC {
    private let tableView = UITableView()
//    private var messages: [MessagesWithInterlocutor]?
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
        //        guard let navBar = navigationController?.navigationBar else { return }
        navigationItem.title = "Чаты"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupTableView() {
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        //        tableView.separatorInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        //        tableView.separatorColor = UIColor.white.withAlphaComponent(0.4)
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
        pubNub.fetchMemberships(uuid: "3dcde054-17ec-48ba-88f9-93fca230ca8a") { (result) in
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
        pubNub.fetchMessageHistory(for: chatIDs, includeActions: false, includeMeta: false, includeUUID: false, includeMessageType: false, page: PubNubBoundedPageBase(start: nil, end: nil, limit: 1) , custom: .init()) { (result) in
            print(result)
            result.map {
                $0.messagesByChannel.values.forEach {
                    
                    $0.forEach {
                        print($0.payload)
                        print($0.payload[rawValue: "text"])
                        
//                        COdableStruct(from: $0.payload)
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
        
        pubNub.publish(channel: "channel_2", message: ["text": "channel 2 message"] ) { result in
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

