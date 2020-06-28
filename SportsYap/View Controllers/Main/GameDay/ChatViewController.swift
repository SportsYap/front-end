//
//  ChatViewController.swift
//  SportsYap
//
//  Created by Master on 2020/6/28.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit
import SDWebImage
import Photos
import Firebase
import InputBarAccessoryView
import MessageKit
import IQKeyboardManagerSwift

class ChatViewController: MessagesViewController {

    var game: Game!
    
    private var docReference: DocumentReference?
    private var messages: [Message] = []

    private let sender = ChatUser(user: User.me)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        customizeViewController()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(hex: "1F263A"),
                                                                   NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
        navigationController?.navigationBar.shadowImage = UIImage.imageWithColor(UIColor.white, size: CGSize(width: 1, height: 1))
        navigationItem.title = "Chatroom"
        
        IQKeyboardManager.shared.enable = false

        loadChat()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = false
    }
}

extension ChatViewController {
    private func customizeViewController() {
        configureNavigationBar()
        configureCollectionView()
        configureInputBar()
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_arrow_black")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onBack))
    }
    
    private func configureCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingAvatarPosition(AvatarPosition(vertical: .messageLabelTop))
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingAvatarPosition(AvatarPosition(vertical: .messageLabelTop))

        messagesCollectionView.messagesCollectionViewFlowLayout.textMessageSizeCalculator.messageLabelFont = UIFont.systemFont(ofSize: 15)

        messagesCollectionView.messagesCollectionViewFlowLayout.textMessageSizeCalculator.incomingMessageLabelInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 12)
        messagesCollectionView.messagesCollectionViewFlowLayout.textMessageSizeCalculator.outgoingMessageLabelInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 16)
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
    }
    
    private func configureInputBar() {
        messageInputBar.delegate = self

//        let imageItem = InputBarButtonItem(type: .custom)
//        imageItem.image = UIImage(named: "ic_picture")
//        imageItem.addTarget(self, action: #selector(onAddPicture), for: .primaryActionTriggered)
        
//        messageInputBar.leftStackView.alignment = .center
//        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
//
//        messageInputBar.setStackViewItems([imageItem], forStack: .left, animated: false)
        
        messageInputBar.backgroundView.backgroundColor = UIColor.white
        messageInputBar.inputTextView.cornerRadius = 22
        messageInputBar.inputTextView.clipsToBounds = true
        messageInputBar.inputTextView.backgroundColor = UIColor(hex: "F1F2F2")
        
        messageInputBar.separatorLine.height = 0
        
        messageInputBar.sendButton.setTitle(nil, for: .normal)
        messageInputBar.sendButton.setImage(UIImage(named: "ic_send_message"), for: .normal)
        
        messageInputBar.inputTextView.placeholder = ""
    }
    
    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ChatViewController {
    @objc private func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func onAddPicture(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default, handler: { (_) in
            self.showImagePicker(sourceType: .camera)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: .default, handler: { (_) in
            self.showImagePicker(sourceType: .photoLibrary)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    private func insertMessage(_ message: Message) {
        save(message)
        
        messages.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1])
            if messages.count >= 2 {
                messagesCollectionView.reloadSections([messages.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    private func isLastSectionVisible() -> Bool {
        guard !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return sender
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if message.sender.senderId == sender.senderId {
            let dateString = message.sentDate.timeAgoSince()
            return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                                                       NSAttributedString.Key.foregroundColor: UIColor(hex: "7f7f7f")])
        } else {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                                                 NSAttributedString.Key.foregroundColor: UIColor(hex: "7f7f7f")])
        }
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if message.sender.senderId == sender.senderId {
            return nil
        }

        let dateString = message.sentDate.timeAgoSince()
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                                                   NSAttributedString.Key.foregroundColor: UIColor(hex: "7f7f7f")])
    }
}

extension ChatViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()

        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }

    private func insertMessages(_ data: [Any]) {
        for component in data {
            if let str = component as? String {
                let message = Message(text: str, user: sender, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            } else if let img = component as? UIImage {
                let message = Message(image: img, user: sender, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
        }
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .black : .white
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 216.0/255, green: 216.0/255, blue: 216.0/255, alpha: 1) : UIColor(red: 0, green: 155.0/255, blue: 1, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .custom({ (view) in
            let radius: CGFloat = 3
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [UIRectCorner.allCorners], cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        })
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let message = message as! Message
        
        avatarView.backgroundColor = UIColor.white
        avatarView.borderColor = UIColor(hex: "009BFF")
        avatarView.borderWidth = 2
        avatarView.set(avatar: Avatar(image: #imageLiteral(resourceName: "default-profile")))
        if message.avatar.isEmpty {
            return
        }
        
        if let localImage = message.localImage {
            avatarView.set(avatar: Avatar(image: localImage))
        } else {
            SDWebImageManager.shared.loadImage(with: URL(string: message.avatar), options: SDWebImageOptions(), progress: nil) { (image, _, error, _, _, _) in
                if let image = image {
                    avatarView.set(avatar: Avatar(image: image))
                }
            }
        }
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            return 18
        }
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if message.sender.senderId == sender.senderId {
            return 0
        }
        return 16
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let asset = info[.phAsset] as? PHAsset {
          let size = CGSize(width: 500, height: 500)
          PHImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFit,
            options: nil) { result, info in
              
            guard let image = result else {
              return
            }
            
            self.insertMessages([image])
          }
        } else if let image = info[.originalImage] as? UIImage {
            insertMessages([image])
        }

        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ChatViewController {
    func createNewChat() {
        let data: [String: Any] = ["gameId": game.id]
        let db = Firestore.firestore().collection("Chats")
        db.addDocument(data: data) { (error) in
            if let error = error {
                print(error)
                return
            } else {
                self.loadChat()
            }
        }
    }
    
    func loadChat() {
        let db = Firestore.firestore().collection("Chats").whereField("gameId", isEqualTo: game.id)
        db.getDocuments { (chatQuerySnap, error) in
            if let error = error {
                print(error)
                return
            } else {
                if let doc = chatQuerySnap!.documents.first {
                    self.docReference = doc.reference
                    doc.reference.collection("thread")
                        .order(by: "created", descending: false)
                        .addSnapshotListener(includeMetadataChanges: true) { (threadQuery, error) in
                            if let error = error {
                                print(error)
                                return
                            } else {
                                self.messages.removeAll()
                                for message in threadQuery!.documents {
                                    if let msg = Message(dictionary: message.data()) {
                                        self.messages.append(msg)
                                    }
                                }
                                self.messagesCollectionView.reloadData()
                                self.messagesCollectionView.scrollToBottom()
                            }
                    }
                } else {
                    self.createNewChat()
                }
            }
        }
    }
    
    private func save(_ message: Message) {
        docReference?.collection("thread").addDocument(data: message.dictionary, completion: { (error) in
            if let error = error {
                print(error)
                return
            }
        })
    }
}
