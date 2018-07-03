//
//  ANIQnaViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/08.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import WCLShineButton
import FirebaseDatabase
import CodableFirebase
import TinyConstraints

protocol ANIQnaViewCellDelegate {
  func cellTapped(qna: FirebaseQna, user: FirebaseUser)
  func reject()
}

class ANIQnaViewCell: UITableViewCell {
  private weak var tapArea: UIView?
  private weak var subTitleLabel: UILabel?
  
  private var qnaImagesViewHeightConstraint: Constraint?
  private var qnaImagesViewHeight: CGFloat = 0.0
  private weak var qnaImagesView: ANIQnaImagesView?
  
  private weak var profileImageView: UIImageView?
  private weak var userNameLabel: UILabel?
  private weak var loveButtonBG: UIView?
  private weak var loveButton: WCLShineButton?
  private weak var loveCountLabel: UILabel?
  private weak var commentButton: UIButton?
  private weak var commentCountLabel: UILabel?
  
  var qna: FirebaseQna? {
    didSet {
      reloadLayout()
      loadUser()
      isLoved()
      observeLove()
    }
  }
  
  var user: FirebaseUser?
  
  var delegate: ANIQnaViewCellDelegate?
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none
    self.backgroundColor = .white
    
    //tapArea
    let tapArea = UIView()
    let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
    tapArea.addGestureRecognizer(cellTapGesture)
    addSubview(tapArea)
    tapArea.edgesToSuperview(excluding: .bottom)
    self.tapArea = tapArea
    
    //subTitleLabel
    let subTitleLabel = UILabel()
    subTitleLabel.font = UIFont.systemFont(ofSize: 14.0)
    subTitleLabel.textColor = ANIColor.subTitle
    subTitleLabel.numberOfLines = 0
    tapArea.addSubview(subTitleLabel)
    subTitleLabel.topToSuperview(offset: 10.0)
    subTitleLabel.leftToSuperview(offset: 10.0)
    subTitleLabel.rightToSuperview(offset: 10.0)
    subTitleLabel.bottomToSuperview()
    self.subTitleLabel = subTitleLabel
    
    //qnaImagesView
    let qnaImagesView = ANIQnaImagesView()
    addSubview(qnaImagesView)
    qnaImagesView.topToBottom(of: tapArea, offset: 10.0)
    qnaImagesView.leftToSuperview()
    qnaImagesView.rightToSuperview()
    qnaImagesViewHeight = UIScreen.main.bounds.width / 2 - 30
    qnaImagesViewHeightConstraint = qnaImagesView.height(0, priority: .defaultHigh)
    self.qnaImagesView = qnaImagesView
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.backgroundColor = ANIColor.bg
    profileImageView.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
    profileImageView.addGestureRecognizer(tapGesture)
    addSubview(profileImageView)
    profileImageView.topToBottom(of: qnaImagesView, offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.width(32.0)
    profileImageView.height(32.0)
    profileImageView.layer.cornerRadius = profileImageView.constraints[0].constant / 2
    profileImageView.layer.masksToBounds = true
    self.profileImageView = profileImageView
    
    //bottomSpace
    let spaceView = UIView()
    spaceView.backgroundColor = ANIColor.bg
    addSubview(spaceView)
    spaceView.topToBottom(of: profileImageView, offset: 10)
    spaceView.leftToSuperview()
    spaceView.rightToSuperview()
    spaceView.height(10.0)
    spaceView.bottomToSuperview()

    //commentCountLabel
    let commentCountLabel = UILabel()
    commentCountLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
    commentCountLabel.textColor = ANIColor.dark
    addSubview(commentCountLabel)
    commentCountLabel.centerY(to: profileImageView)
    commentCountLabel.rightToSuperview(offset: 20.0)
    commentCountLabel.width(30.0)
    commentCountLabel.height(20.0)
    self.commentCountLabel = commentCountLabel

    //commentButton
    let commentButton = UIButton()
    commentButton.setImage(UIImage(named: "comment"), for: .normal)
    commentButton.addTarget(self, action: #selector(cellTapped), for: .touchUpInside)
    addSubview(commentButton)
    commentButton.centerY(to: profileImageView)
    commentButton.rightToLeft(of: commentCountLabel, offset: -10.0)
    commentButton.width(25.0)
    commentButton.height(24.0)
    self.commentButton = commentButton

    //loveCountLabel
    let loveCountLabel = UILabel()
    loveCountLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
    loveCountLabel.textColor = ANIColor.dark
    addSubview(loveCountLabel)
    loveCountLabel.centerY(to: profileImageView)
    loveCountLabel.rightToLeft(of: commentButton, offset: -10.0)
    loveCountLabel.width(30.0)
    loveCountLabel.height(20.0)
    self.loveCountLabel = loveCountLabel
    
    //loveButtonBG
    let loveButtonBG = UIView()
    loveButtonBG.isUserInteractionEnabled = false
    let loveButtonBGtapGesture = UITapGestureRecognizer(target: self, action: #selector(loveButtonBGTapped))
    loveButtonBG.addGestureRecognizer(loveButtonBGtapGesture)
    addSubview(loveButtonBG)
    loveButtonBG.centerY(to: profileImageView)
    loveButtonBG.rightToLeft(of: loveCountLabel, offset: -10.0)
    loveButtonBG.width(20.0)
    loveButtonBG.height(20.0)
    self.loveButtonBG = loveButtonBG

    //loveButton
    var param = WCLShineParams()
    param.bigShineColor = ANIColor.red
    param.smallShineColor = ANIColor.pink
    let loveButton = WCLShineButton(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0), params: param)
    loveButton.fillColor = ANIColor.red
    loveButton.color = ANIColor.gray
    loveButton.image = .heart
    loveButton.addTarget(self, action: #selector(love), for: .valueChanged)
    addSubview(loveButton)
    loveButton.centerY(to: profileImageView)
    loveButton.rightToLeft(of: loveCountLabel, offset: -10.0)
    loveButton.width(21.0)
    loveButton.height(21.0)
    self.loveButton = loveButton

    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.font = UIFont.systemFont(ofSize: 13.0)
    userNameLabel.textColor = ANIColor.subTitle
    addSubview(userNameLabel)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToLeft(of: loveButton, offset: -10)
    userNameLabel.centerY(to: profileImageView)
    userNameLabel.height(20.0)
    self.userNameLabel = userNameLabel
  }
  
  private func reloadLayout() {
    guard let subTitleLabel = self.subTitleLabel,
          let qnaImagesView = self.qnaImagesView,
          let loveButtonBG = self.loveButtonBG,
          let loveButton = self.loveButton,
          let loveCountLabel = self.loveCountLabel,
          let commentCountLabel = self.commentCountLabel,
          let qna = self.qna,
          let qnaImagesViewHeightConstraint = self.qnaImagesViewHeightConstraint else { return }
    
    subTitleLabel.text = qna.qna

    if let qnaImageUrls = qna.qnaImageUrls {
      qnaImagesViewHeightConstraint.constant = qnaImagesViewHeight
      qnaImagesView.imageUrls = qnaImageUrls
    } else {
      qnaImagesViewHeightConstraint.constant = 0
    }

    if ANISessionManager.shared.isAnonymous {
      loveButtonBG.isUserInteractionEnabled = true
      loveButton.isEnabled = false
    } else {
      loveButtonBG.isUserInteractionEnabled = false
      loveButton.isEnabled = true
    }
    loveButton.isSelected = false
    if let loveIds = qna.loveIds {
      loveCountLabel.text = "\(loveIds.count)"
    } else {
      loveCountLabel.text = "0"
    }
    
    if let commentIds = qna.commentIds {
      commentCountLabel.text = "\(commentIds.count)"
    } else {
      commentCountLabel.text = "0"
    }
  }
  
  private func reloadUserLayout(user: FirebaseUser) {
    guard let userNameLabel = self.userNameLabel,
          let profileImageView = self.profileImageView,
          let profileImageUrl = user.profileImageUrl,
          let userName = user.userName else { return }
    
    profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
    userNameLabel.text = userName
  }
  
  private func loadUser() {
    guard let qna = self.qna else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_USERS).child(qna.userId).observeSingleEvent(of: .value, with: { (userSnapshot) in
        if let userValue = userSnapshot.value {
          do {
            let user = try FirebaseDecoder().decode(FirebaseUser.self, from: userValue)
            self.user = user
            
            DispatchQueue.main.async {
              self.reloadUserLayout(user: user)
            }
          } catch let error {
            print(error)
          }
        }
      })
    }
  }
  
  private func observeLove() {
    guard let qna = self.qna,
          let qnaId = qna.id else { return }
    
    let databaseRef = Database.database().reference()
    DispatchQueue.global().async {
      databaseRef.child(KEY_QNAS).child(qnaId).child(KEY_LOVE_IDS).observe(.value) { (snapshot) in
        if let loveIds = snapshot.value as? [String: AnyObject] {
          DispatchQueue.main.async {
            guard let loveCountLabel = self.loveCountLabel else { return }
            
            loveCountLabel.text = "\(loveIds.count)"
          }
        } else {
          DispatchQueue.main.async {
            guard let loveCountLabel = self.loveCountLabel else { return }
            
            loveCountLabel.text = "0"
          }
        }
      }
    }
  }
  
  func unobserveLove() {
    guard let qna = self.qna,
          let qnaId = qna.id else { return }
    
    let databaseRef = Database.database().reference()
    DispatchQueue.global().async {
      databaseRef.child(KEY_QNAS).child(qnaId).child(KEY_LOVE_IDS).removeAllObservers()
    }
  }
  
  private func isLoved() {
    guard let qna = self.qna,
          let qnaId = qna.id,
          let currentUserId = ANISessionManager.shared.currentUserUid else { return }
    
    let databaseRef = Database.database().reference()
    DispatchQueue.global().async {
      databaseRef.child(KEY_QNAS).child(qnaId).child(KEY_LOVE_IDS).observeSingleEvent(of: .value) { (snapshot) in
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot {
            if snapshot.key == currentUserId {
              DispatchQueue.main.async {
                guard let loveButton = self.loveButton else { return }
                
                loveButton.isSelected = true
              }
            }
          }
        }
      }
    }
  }
  
  //MARK: action
  @objc private func love() {
    guard let qna = self.qna,
          let qnaId = qna.id,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let loveButton = self.loveButton else { return }
    
    let databaseRef = Database.database().reference()
    if loveButton.isSelected == true {
      DispatchQueue.global().async {
        databaseRef.child(KEY_QNAS).child(qnaId).child(KEY_LOVE_IDS).updateChildValues([currentUserId: true])
        let date = ANIFunction.shared.getToday()
        databaseRef.child(KEY_USERS).child(currentUserId).child(KEY_LOVE_QNA_IDS).updateChildValues([qnaId: date])
      }
    } else {
      DispatchQueue.global().async {
        databaseRef.child(KEY_QNAS).child(qnaId).child(KEY_LOVE_IDS).child(currentUserId).removeValue()
        databaseRef.child(KEY_USERS).child(currentUserId).child(KEY_LOVE_QNA_IDS).child(qnaId).removeValue()
      }
    }
  }
  
  @objc private func loveButtonBGTapped() {
    self.delegate?.reject()
  }
  
  @objc private func profileImageViewTapped() {
    guard let qna = self.qna else { return }
    
    ANINotificationManager.postProfileImageViewTapped(userId: qna.userId)
  }
  
  @objc private func cellTapped() {
    guard let qna = self.qna,
          let user = self.user else { return }
    
    if !ANISessionManager.shared.isAnonymous {
      self.delegate?.cellTapped(qna: qna, user: user)
    } else {
      self.delegate?.reject()
    }
  }
}
