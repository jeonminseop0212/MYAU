//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIRecuruitView: UIView {

  var recruitCollectionView: UICollectionView?
  
  private var testRecruitLists = [Recurit]()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupTestData()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let flowlayout = UICollectionViewFlowLayout()
    flowlayout.scrollDirection = .vertical
    flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowlayout)
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    collectionView.contentInset = UIEdgeInsets(top: ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT, left: 0, bottom: 0, right: 0)
    collectionView.scrollIndicatorInsets  = UIEdgeInsets(top: ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT, left: 0, bottom: 0, right: 0)
    collectionView.backgroundColor = .white
    collectionView.register(ANIRecruitViewCell.self, forCellWithReuseIdentifier: id)
    collectionView.alwaysBounceVertical = true
    collectionView.dataSource = self
    collectionView.delegate = self
    addSubview(collectionView)
    collectionView.edgesToSuperview()
    self.recruitCollectionView = collectionView
  }
  
  private func setupTestData() {
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let recruit1 = Recurit(recruitImage: UIImage(named: "cat1")!, title: "かわいい猫ちゃんの里親になって >_<", subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user1, supportCount: 10, loveCount: 10)
    let recruit2 = Recurit(recruitImage: UIImage(named: "cat2")!, title: "かわいい猫ちゃんの里親になって >_<", subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user2, supportCount: 5, loveCount: 15)
    let recruit3 = Recurit(recruitImage: UIImage(named: "cat1")!, title: "かわいい猫ちゃんの里親になって >_<", subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user3, supportCount: 10, loveCount: 10)
    self.testRecruitLists = [recruit1, recruit2, recruit3]
  }
}

extension ANIRecuruitView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return testRecruitLists.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANIRecruitViewCell
    cell.recruitImageView.image = testRecruitLists[indexPath.item].recruitImage
    cell.titleLabel.text = testRecruitLists[indexPath.item].title
    cell.subTitleTextView.text = testRecruitLists[indexPath.item].subTitle
    cell.profileImageView.image = testRecruitLists[indexPath.item].user.profileImage
    cell.userNameLabel.text = testRecruitLists[indexPath.item].user.name
    cell.supportCountLabel.text = "\(testRecruitLists[indexPath.item].supportCount)"
    cell.loveCountLabel.text = "\(testRecruitLists[indexPath.item].loveCount)"
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 320.0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
}
