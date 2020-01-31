import UIKit

protocol ContactCellDelegate: class {
    func onAvatarTapped(at index: Int)
}

class ContactCell: UITableViewCell {

    public static let cellHeight: CGFloat = 74.5
    weak var delegate: ContactCellDelegate?
    var rowIndex = -1
    private let badgeSize: CGFloat = 54
    private let imgSize: CGFloat = 20

    lazy var avatar: InitialsBadge = {
        let badge = InitialsBadge(size: badgeSize)
        badge.setColor(UIColor.lightGray)
        badge.isAccessibilityElement = false
        return badge
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.lineBreakMode = .byTruncatingTail
        label.textColor = DcColors.defaultTextColor
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1), for: NSLayoutConstraint.Axis.horizontal)
        // label.makeBorder()
        return label

    }()

    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hexString: "848ba7")
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hexString: "848ba7")
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 2), for: NSLayoutConstraint.Axis.horizontal)
        // label.makeBorder()
        return label
    }()

    private let deliveryStatusIndicator: UIImageView = {
        let view = UIImageView()
        view.tintColor = UIColor.green
        view.isHidden = true
        return view
    }()

    private let unreadMessageCounter: MessageCounter = {
        let view = MessageCounter(count: 0, size: 20)
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = DcColors.chatBackgroundColor
        contentView.backgroundColor = DcColors.chatBackgroundColor
        setupSubviews()
    }

    private func setupSubviews() {
        let margin: CGFloat = 10

        avatar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatar)

        contentView.addConstraints([
            avatar.constraintWidthTo(badgeSize),
            avatar.constraintHeightTo(badgeSize),
            avatar.constraintAlignLeadingTo(contentView, paddingLeading: badgeSize / 4),
            avatar.constraintCenterYTo(contentView),
        ])

        deliveryStatusIndicator.translatesAutoresizingMaskIntoConstraints = false
        deliveryStatusIndicator.heightAnchor.constraint(equalToConstant: 20).isActive = true
        deliveryStatusIndicator.widthAnchor.constraint(equalToConstant: 20).isActive = true

        let myStackView = UIStackView()
        myStackView.translatesAutoresizingMaskIntoConstraints = false
        myStackView.clipsToBounds = true

        let toplineStackView = UIStackView()
        toplineStackView.axis = .horizontal

        let bottomLineStackView = UIStackView()
        bottomLineStackView.axis = .horizontal

        toplineStackView.addArrangedSubview(nameLabel)
        toplineStackView.addArrangedSubview(timeLabel)

        bottomLineStackView.addArrangedSubview(emailLabel)
        bottomLineStackView.addArrangedSubview(deliveryStatusIndicator)
        bottomLineStackView.addArrangedSubview(unreadMessageCounter)

        contentView.addSubview(myStackView)
        myStackView.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: margin).isActive = true
        myStackView.centerYAnchor.constraint(equalTo: avatar.centerYAnchor).isActive = true
        myStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin).isActive = true
        myStackView.axis = .vertical
        myStackView.addArrangedSubview(toplineStackView)
        myStackView.addArrangedSubview(bottomLineStackView)

        if delegate != nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(onAvatarTapped))
            avatar.addGestureRecognizer(tap)
        }
    }

    func setVerified(isVerified: Bool) {
        avatar.setVerified(isVerified)
    }

    func setImage(_ img: UIImage) {
        avatar.setImage(img)
    }

    func resetBackupImage() {
        avatar.setColor(UIColor.clear)
        avatar.setName("")
    }

    func setBackupImage(name: String, color: UIColor) {
        avatar.setColor(color)
        avatar.setName(name)
    }

    func setUnreadMessageCounter(_ count: Int) {
        unreadMessageCounter.setCount(count)
    }

    func setDeliveryStatusIndicator(_ status: Int) {
        var indicatorImage: UIImage?
        switch Int32(status) {
        case DC_STATE_OUT_PENDING, DC_STATE_OUT_PREPARING:
            indicatorImage = #imageLiteral(resourceName: "ic_hourglass_empty_36pt").withRenderingMode(.alwaysTemplate)
            deliveryStatusIndicator.tintColor = UIColor.black.withAlphaComponent(0.5)
        case DC_STATE_OUT_DELIVERED:
            indicatorImage = #imageLiteral(resourceName: "ic_done_36pt").withRenderingMode(.alwaysTemplate)
            deliveryStatusIndicator.tintColor = DcColors.checkmarkGreen
        case DC_STATE_OUT_FAILED:
            indicatorImage = #imageLiteral(resourceName: "ic_error_36pt").withRenderingMode(.alwaysTemplate)
            deliveryStatusIndicator.tintColor = UIColor.red
        case DC_STATE_OUT_MDN_RCVD:
            indicatorImage = #imageLiteral(resourceName: "ic_done_all_36pt").withRenderingMode(.alwaysTemplate)
            deliveryStatusIndicator.tintColor = DcColors.checkmarkGreen
        default:
            break
        }
        if indicatorImage != nil && unreadMessageCounter.isHidden {
            deliveryStatusIndicator.isHidden = false
        } else {
            deliveryStatusIndicator.isHidden = true
        }
        deliveryStatusIndicator.image = indicatorImage
    }

    func setTimeLabel(_ timestamp: Int64?) {
        let timestamp = timestamp ?? 0
        if timestamp != 0 {
            timeLabel.isHidden = false
            timeLabel.text = DateUtils.getBriefRelativeTimeSpanString(timeStamp: Double(timestamp))
        } else {
            timeLabel.isHidden = true
            timeLabel.text = nil
        }
    }

    func setColor(_ color: UIColor) {
        avatar.setColor(color)
    }

    @objc func onAvatarTapped() {
        if let delegate = delegate {
            if rowIndex == -1 {
                return
            }
            delegate.onAvatarTapped(at: rowIndex)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    /*
     this method can be deleted after searchBarContactList-branch was merged into master
     */

    func updateCell(cellViewModel: AvatarCellViewModel) {
        // subtitle
        emailLabel.attributedText = cellViewModel.subtitle.boldAt(indexes: cellViewModel.subtitleHighlightIndexes, fontSize: emailLabel.font.pointSize)

        switch cellViewModel.type {
        case .CHAT(let chatData):
            let chat = DcChat(id: chatData.chatId)

            // text bold if chat contains unread messages - otherwise hightlight search results if needed
            if chatData.unreadMessages > 0 {
                nameLabel.attributedText = NSAttributedString(string: cellViewModel.title, attributes: [ .font: UIFont.systemFont(ofSize: 16, weight: .bold) ])
            } else {
                nameLabel.attributedText = cellViewModel.title.boldAt(indexes: cellViewModel.titleHighlightIndexes, fontSize: nameLabel.font.pointSize)
            }

            if let img = chat.profileImage {
                resetBackupImage()
                setImage(img)
            } else {
              setBackupImage(name: chat.name, color: chat.color)
            }
            setVerified(isVerified: chat.isVerified)
            setTimeLabel(chatData.summary.timestamp)
            setUnreadMessageCounter(chatData.unreadMessages)
            setDeliveryStatusIndicator(chatData.summary.state)

        case .CONTACT(let contactData):
            let contact = DcContact(id: contactData.contactId)
            nameLabel.attributedText = cellViewModel.title.boldAt(indexes: cellViewModel.titleHighlightIndexes, fontSize: nameLabel.font.pointSize)
            avatar.setName(cellViewModel.title)
            avatar.setColor(contact.color)
        }
    }
}
