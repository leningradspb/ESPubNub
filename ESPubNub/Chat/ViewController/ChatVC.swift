//
//  ChatVC.swift
//  ESPubNub
//
//  Created by Eduard Sinyakov on 03.06.2021.
//


import UIKit
import PubNub

class ChatVC: BaseVC {
    private let tableView = UITableView()
    private let inputMessageStack = HorizontalStackView(distribution: .fill, spacing: 10, alignment: .bottom)
    private let uploadImageButton = UIButton()
    private let sentMessageButton = UIButton()
    private let messageTextView = UITextView()
    private var model: ChatInitModel!
    private var messages: [Message] = []
    private let placeholder = "Введите текст"
    private let userImage = UIImageView()
    private let userNickName = UILabel()
    
    private var isNeedCreateConversation = false
    
//    private var partnerName: String?
//    private var partnerImageURL: String? {
//        didSet {
//            if let url = URL(string: partnerImageURL ?? "") {
//                DispatchQueue.main.async { [weak self] in
////                    self?.userImage.kf.setImage(with: url)
//                    self?.userNickName.text = self?.partnerName
//                }
//            }
//        }
//    }
    
    private var partnerID: String {
        model.partnerID
    }
    
    private var channelID: String {
        model.channelID
    }
    
    init(model: ChatInitModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.model = model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar()
        setupTableView()
        setupInputMessageView()
        loadMessages()
        setupMessageListener()
//        setupTapRecognizer(for: view, action: #selector(hideKeyboard))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    private func setupNavigationBar() {
//        guard let navBar = navigationController?.navigationBar else { return }
//        navigationItem.title = "Начать чат"
//        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        let userBar = UIView()
//        userBar.backgroundColor = .green
        navigationItem.titleView = userBar
        userBar.addSubviews([userImage, userNickName])
        
        userImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(5)
            $0.height.width.equalTo(54)
//            $0.bottom.equalToSuperview().offset(-5)
        }
        userImage.layer.cornerRadius = 27
        userImage.contentMode = .scaleAspectFill
        
        userNickName.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(userImage.snp.trailing)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview()
        }
        userNickName.textColor = .white
        userNickName.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        userBar.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.width.equalTo(150)
            $0.height.equalTo(44)
//            $0.bottom.equalToSuperview()
        }
        
        userImage.image = UIImage(named: "guy")
        userNickName.text = "User Nick"
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
//            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
//            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.register(MeSenderCell.self, forCellReuseIdentifier: MeSenderCell.identifier)
        tableView.register(PartnerSenderCell.self, forCellReuseIdentifier: PartnerSenderCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top = 15
    }
    
    private func setupInputMessageView() {
        let iconConfig = UIImage.SymbolConfiguration(scale: .large)
        view.addSubview(inputMessageStack)
        
        inputMessageStack.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
//            $0.bottom.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        let backViewForUploadImageButton = UIView()
        backViewForUploadImageButton.backgroundColor = .clear
        
        inputMessageStack.addArranged(subviews: [backViewForUploadImageButton, messageTextView])
        backViewForUploadImageButton.addSubview(uploadImageButton)
        view.addSubview(sentMessageButton)
        sentMessageButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.bottom.equalTo(messageTextView.snp.bottom).offset(-5)
            $0.trailing.equalTo(messageTextView.snp.trailing).offset(-10)
        }
        let sentImage = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: iconConfig)
        sentMessageButton.setImage(sentImage, for: .normal)
        sentMessageButton.tintColor = .scarlet
        sentMessageButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        uploadImageButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-2)
            $0.height.width.equalTo(30)
        }
        
        let uploadImage = UIImage(systemName: "photo.fill", withConfiguration: iconConfig)
        uploadImageButton.setImage(uploadImage, for: .normal)
        uploadImageButton.tintColor = .scarlet
        uploadImageButton.addTarget(self, action: #selector(showImagePicker), for: .touchUpInside)
        
        messageTextView.delegate = self
        messageTextView.backgroundColor = .black
        messageTextView.layer.cornerRadius = 10
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = UIColor.darkGray.cgColor
        messageTextView.text = placeholder
        messageTextView.textColor = .darkGray
        messageTextView.autocorrectionType = .no
        messageTextView.keyboardAppearance = .dark
        messageTextView.isScrollEnabled = false
        messageTextView.font = UIFont.systemFont(ofSize: 14)
        messageTextView.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 10, right: 40)
    }
    
    private func loadMessages() {
        pubNub.fetchMessageHistory(for: [channelID]) { [weak self] result in
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
                        self.messages.append(Message(fromID: fromID, message: message, toID: toID, timestamp: timestampDouble, channel: channel))
                    }
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.tableView.reloadData()
                        if !self.messages.isEmpty {
                            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                        }
                    }
                }
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
    
    @objc private func sendMessage() {
        let timestamp: Double = Date().timeIntervalSince1970
        let timestampString: String = String(format: "%f", timestamp)
        pubNub.publish(channel: model.channelID, message: ["text": messageTextView.text, "timestamp": timestampString, "fromID": myID, "toID": "someID"] ) { result in
            switch result {
            case let .success(response):
                print("succeeded: \(response.description)")
                
            case let .failure(error):
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func showImagePicker() {
        print("showImagePicker")
    }
    
//    @objc private func hideKeyboard() {
//        messageTextField.endEditing(true)
//    }

   
    struct ChatInitModel {
        let partnerID: String
        let channelID: String
    }

}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < messages.count {
            let message = messages[indexPath.row]
            
            if message.fromID == myID {
                let cell = tableView.dequeueReusableCell(withIdentifier: MeSenderCell.identifier, for: indexPath) as! MeSenderCell
                cell.updateMeSenderCell(with: message.message ?? "")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: PartnerSenderCell.identifier, for: indexPath) as! PartnerSenderCell
                cell.updatePartnerSenderCell(with: message.message ?? "")
                return cell
            }
        }
        
        return UITableViewCell()
    }
}

extension ChatVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            messageTextView.text = ""
            messageTextView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            messageTextView.text = placeholder
            messageTextView.textColor = .darkGray
        }
    }
}


extension Dictionary where Value: Equatable {
    func key(from value: Value) -> Key? {
        return self.first(where: { $0.value == value })?.key
    }
}

// MARK: - KEYBOARD BLOCK
extension ChatVC {
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
        //            self.view.frame.origin.y = -keyboardSize.size.height + (self.tabBarController?.tabBar.bounds.height)!
        //        }
        var _kbSize:CGSize!
        
        if let info = notification.userInfo {
            
            let frameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
            
            //  Getting UIKeyboardSize.
            if let kbFrame = info[frameEndUserInfoKey] as? CGRect {
                
                let screenSize = UIScreen.main.bounds
                
                //Calculating actual keyboard displayed size, keyboard frame may be different when hardware keyboard is attached (Bug ID: #469) (Bug ID: #381)
                let intersectRect = kbFrame.intersection(screenSize)
                
                if intersectRect.isNull {
                    _kbSize = CGSize(width: screenSize.size.width, height: 0)
                } else {
                    _kbSize = intersectRect.size
                }
                
                if _kbSize.height != 0 {
                    self.view.frame.origin.y = -_kbSize.height 
                } else {
                    self.view.frame.origin.y = 0
                }
                //                      print("Your Keyboard Size \(_kbSize)")
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}
