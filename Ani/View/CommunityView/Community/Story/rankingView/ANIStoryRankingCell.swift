//
//  ANIStoryRankingeCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/11/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

protocol ANIStoryRankingCellDelegate {
  func loadedUser(user: FirebaseUser)
}

class ANIStoryRankingCell: UICollectionViewCell {
  
  let RANKING_COLLECTION_VIEW_CELL_WIDHT: CGFloat = ceil(UIScreen.main.bounds.width / 2)
  let MARGIN: CGFloat = 30.0
  
  private weak var base: UIView?
  private weak var storyImageView: UIImageView?
  
  private weak var crownImageView: UIImageView?
  
  let STORY_LABEL_HEIHGT: CGFloat = 35.0
  private weak var storyLabel: UILabel?
  
  let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 30.0
  private weak var profileImageView: UIImageView?
  
  private weak var userNameLabel: UILabel?
  
  private weak var blurBackGroundView: UIView?
  private weak var blockImageView: UIImageView?
  private weak var blockAlertLabel: UILabel?
  
  static var share = ANIStoryRankingCell()
  
  var rankingStory: FirebaseStory? {
    didSet {
      if user == nil {
        loadUser()
      }
      reloadLayout()
    }
  }
  
  var user: FirebaseUser? {
    didSet {
      reloadUserLayout()
    }
  }
  
  var crownImage: UIImage? {
    didSet {
      guard let crownImageView = self.crownImageView,
            let crownImage = self.crownImage else { return }
      
      crownImageView.image = crownImage
    }
  }
  
  var delegate: ANIStoryRankingCellDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = ANIColor.bg
    
    //base
    let base = UIView()
    base.backgroundColor = .white
    base.layer.cornerRadius = 10.0
    base.layer.masksToBounds = true
    addSubview(base)
    base.edgesToSuperview()
    self.base = base
    
    //storyImageView
    let storyImageView = UIImageView()
    storyImageView.backgroundColor = ANIColor.gray
    base.addSubview(storyImageView)
    storyImageView.edgesToSuperview(excluding: .bottom)
    storyImageView.height(RANKING_COLLECTION_VIEW_CELL_WIDHT)
    self.storyImageView = storyImageView
    
    //storyLabel
    let storyLabel = UILabel()
    storyLabel.text = "story"
    storyLabel.font = UIFont.systemFont(ofSize: 14.0)
    storyLabel.textColor = ANIColor.subTitle
    storyLabel.numberOfLines = 2
    base.addSubview(storyLabel)
    storyLabel.topToBottom(of: storyImageView, offset: 10.0)
    storyLabel.leftToSuperview(offset: 10.0)
    storyLabel.rightToSuperview(offset: -10.0)
    storyLabel.height(STORY_LABEL_HEIHGT)
    self.storyLabel = storyLabel
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.backgroundColor = ANIColor.gray
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_VIEW_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    profileImageView.contentMode = .scaleAspectFill
    base.addSubview(profileImageView)
    profileImageView.topToBottom(of: storyLabel, offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.width(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_VIEW_HEIGHT)
    self.profileImageView = profileImageView
    
    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.font = UIFont.systemFont(ofSize: 13.0)
    userNameLabel.textColor = ANIColor.subTitle
    userNameLabel.numberOfLines = 2
    userNameLabel.text = "user name"
    base.addSubview(userNameLabel)
    userNameLabel.centerY(to: profileImageView)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToSuperview(offset: -10.0)
    self.userNameLabel = userNameLabel
    
    //blurBackGroundView
    let blurBackGroundView = UIView()
    blurBackGroundView.isHidden = true
    base.addSubview(blurBackGroundView)
    blurBackGroundView.edgesToSuperview()
    self.blurBackGroundView = blurBackGroundView
    
    //effectView
    let blurEffect = UIBlurEffect(style: .light)
    let effectView = UIVisualEffectView(effect: blurEffect)
    blurBackGroundView.addSubview(effectView)
    effectView.edgesToSuperview()
    
    //crownImageView
    let crownImageView = UIImageView()
    crownImageView.backgroundColor = .clear
    base.addSubview(crownImageView)
    crownImageView.topToSuperview(offset: 10.0)
    crownImageView.leftToSuperview(offset: 10.0)
    self.crownImageView = crownImageView
    
    //blockImageView
    let blockImageView = UIImageView()
    blockImageView.image = UIImage(named: "notSee")
    blockImageView.contentMode = .scaleAspectFill
    blurBackGroundView.addSubview(blockImageView)
    blockImageView.width(self.RANKING_COLLECTION_VIEW_CELL_WIDHT * 0.15)
    blockImageView.heightToWidth(of: blockImageView)
    blockImageView.centerXToSuperview()
    blockImageView.centerYToSuperview(offset: -20.0)
    self.blockImageView = blockImageView
    
    //blockAlertLabel
    let blockAlertLabel = UILabel()
    blockAlertLabel.text = "ブロックした\nストーリーです"
    blockAlertLabel.textColor = ANIColor.dark
    blockAlertLabel.textAlignment = .center
    blockAlertLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
    blockAlertLabel.numberOfLines = 0
    blurBackGroundView.addSubview(blockAlertLabel)
    blockAlertLabel.topToBottom(of: blockImageView, offset: 10)
    blockAlertLabel.leftToSuperview(offset: 10)
    blockAlertLabel.rightToSuperview(offset: -10)
    self.blockAlertLabel = blockAlertLabel
  }
  
  private func reloadLayout() {
    guard let rankingStory = self.rankingStory,
          let storyImageUrls = rankingStory.storyImageUrls,
          let storyImageView = self.storyImageView,
          let storyLabel = self.storyLabel,
          let blurBackGroundView = self.blurBackGroundView else { return }
    
    storyImageView.sd_setImage(with: URL(string: storyImageUrls[0]), completed: nil)
    storyLabel.text = rankingStory.story
    
    if isBlockStory(story: rankingStory) {
      blurBackGroundView.isHidden = false
    } else {
      blurBackGroundView.isHidden = true
    }
  }
  
  private func reloadUserLayout() {
    guard let userNameLabel = self.userNameLabel,
          let profileImageView = self.profileImageView else { return }
    
    if let user = self.user, let profileImageUrl = user.profileImageUrl {
      profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
    } else {
      profileImageView.image = UIImage()
    }
    
    if let user = self.user, let userName = user.userName {
      userNameLabel.text = userName
    } else {
      userNameLabel.text = "user name"
    }
  }
  
  private func isBlockStory(story: FirebaseStory) -> Bool {
    guard let currentUserUid = ANISessionManager.shared.currentUserUid else { return false }
    
    if let blockUserIds = ANISessionManager.shared.blockUserIds, blockUserIds.contains(story.userId) {
      return true
    }
    if let blockingUserIds = ANISessionManager.shared.blockingUserIds, blockingUserIds.contains(story.userId) {
      return true
    }
    if let hideUserIds = story.hideUserIds, hideUserIds.contains(currentUserUid) {
      return true
    }
    if story.storyImageUrls == nil && story.recruitId == nil {
      return true
    }
    
    return false
  }
}

//MARK: data
extension ANIStoryRankingCell {
  private func loadUser() {
    guard let story = self.rankingStory else { return }
    
    DispatchQueue.global().async {
      let database = Firestore.firestore()
      database.collection(KEY_USERS).document(story.userId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot, let data = snapshot.data() else { return }
        
        do {
          let user = try FirebaseDecoder().decode(FirebaseUser.self, from: data)
          self.user = user
          self.delegate?.loadedUser(user: user)
        } catch let error {
          DLog(error)
        }
      })
    }
  }
}