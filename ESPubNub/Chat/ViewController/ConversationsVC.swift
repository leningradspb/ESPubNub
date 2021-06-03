/*
import UIKit

class ConversationsVC: UIViewController {
    private let tableView = UITableView()
//    private var messages: [MessagesWithInterlocutor]?
    private var conversations: [SnapshotConversation.Conversation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        observeConversations()
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
        self.reference.child(ReferenceKeys.conversations).child(myID!).observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            let conversations = SnapshotConversation.init(with: snapshot)?.conversations
            
            if let conversations = conversations {
                self.conversations = conversations.sorted { (m1, m2) -> Bool in
                    if let t1 = m1.lastMessage?.timestamp, let t2 = m2.lastMessage?.timestamp {
                        return t1 > t2
                    } else {
                        return false
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func showChat(by index: Int) {
        let conversation = conversations[index]
        
        let pairID = conversation.user?.userID ?? ""
        
        let model = ChatVC.ChatInitModel(partnerID: pairID, autoID: nil, path: nil)
        let vc = ChatVC(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
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
*/
