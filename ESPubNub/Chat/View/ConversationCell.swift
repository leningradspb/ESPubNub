
import UIKit
import SnapKit

class ConversationCell: UITableViewCell {
    private let backgroundGreyView = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let lastMessageLabel = UILabel()
    private let messageDateLabel = UILabel()
    private let isReadView = UIView()
    private let isRedBackground = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        contentView.backgroundColor = .black
        selectionStyle = .none
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        lastMessageLabel.text = nil
        messageDateLabel.text = nil
        profileImageView.image = nil
//        isRedBackground.isHidden = true
    }
    
    private func setupUI() {
        contentView.addSubview(backgroundGreyView)
        backgroundGreyView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-5)
        }
        backgroundGreyView.layer.cornerRadius = 10
        backgroundGreyView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        let messageStack = HorizontalStackView(spacing: 5)
        backgroundGreyView.addSubviews([profileImageView, nameLabel, messageDateLabel, messageStack])
        // MARK: -profileImageView
        profileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(5)
            $0.width.height.equalTo(90)
        }
        profileImageView.layer.cornerRadius = 45
//        profileImageView.image = UIImage(named: "successGirl")
        
        // MARK: - messageDateLabel
        messageDateLabel.text = "10.05.2021"
        messageDateLabel.font = UIFont.systemFont(ofSize: 12)
        messageDateLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        messageDateLabel.textAlignment = .right
        messageDateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        // MARK: - nameLabel
        
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
            $0.trailing.lessThanOrEqualTo(messageDateLabel.snp.leading).offset(-5)
        }
        
        
        // MARK: - isReadView
        isRedBackground.backgroundColor = .clear
        isRedBackground.addSubview(isReadView)
        messageStack.addArranged(subviews: [lastMessageLabel, isRedBackground])
        
        isRedBackground.snp.makeConstraints {
            $0.width.equalTo(10)
        }
        
        messageStack.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        isReadView.backgroundColor = .scarlet
        isReadView.snp.makeConstraints {
            $0.width.height.equalTo(10)
            $0.centerY.centerX.equalToSuperview()
        }
        isReadView.layer.cornerRadius = 5
        
        // MARK: - lastMessageLabel
//        lastMessageLabel.text = "asfjal sagasg sagasg q  1! g sagasg q  1! gasg q  1! g sagasg q  1!"
        lastMessageLabel.numberOfLines = 2
        lastMessageLabel.lineBreakMode = .byTruncatingTail
        lastMessageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lastMessageLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        lastMessageLabel.contentMode = .bottom
    }
    
    func updateConversationCell(with model: ConversationData.Conversation) {
        nameLabel.text = "model.user?.nickName"
        lastMessageLabel.text = model.lastMessage?.message
//        print("last = \(model)")
        
//        if let urlString = model.user?.userImageURL, let url = URL(string: urlString) {
//            profileImageView.kf.setImage(with: url)
//        }
        
        if let seconds = model.lastMessage?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: TimeInterval(seconds))
            let isToday = Calendar.current.isDateInToday(timestampDate)
            let isYesterday = Calendar.current.isDateInYesterday(timestampDate)
            
            if isToday {
                messageDateLabel.text = "Сегодня"
            } else if isYesterday {
                messageDateLabel.text = "Вчера"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ru_RU")
                dateFormatter.dateFormat = "dd MMM, hh:mm"
                messageDateLabel.text = dateFormatter.string(from: timestampDate)
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Model {
        let userID, userName, lastMessage, imageUrl: String?
        let messageDate: TimeInterval?
        let isRead: Bool?
    }
}

