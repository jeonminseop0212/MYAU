//
//  RecruitCategoriesView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/05.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIRecruitCategoriesView: UIView {
  
  private weak var categoryCollectionView: UICollectionView?
  
  private var testArr = [String]()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setTestModel()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let flowlayout = UICollectionViewFlowLayout()
    flowlayout.scrollDirection = .horizontal
    flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowlayout)
    collectionView.register(ANIRecruitCategoryCell.self, forCellWithReuseIdentifier: "Cell")
    collectionView.backgroundColor = .white
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.alwaysBounceHorizontal = true
    collectionView.dataSource = self
    collectionView.delegate = self
    addSubview(collectionView)
    collectionView.edgesToSuperview()
    self.categoryCollectionView = collectionView
  }
  
  private func setTestModel() {
    let arr = [
      "고양이",
      "강아지",
      "뱀",
      "햄스터",
      "금붕어"
    ]
    
    self.testArr = arr
  }
}

extension ANIRecruitCategoriesView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return testArr.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ANIRecruitCategoryCell
    cell.categoryLabel?.text = testArr[indexPath.item]
    cell.backgroundColor = ANIColor.lightGray
    cell.layer.cornerRadius = cell.frame.height / 2
    cell.layer.masksToBounds = true
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = ANIRecruitCategoryCell.sizeWithCategory(category: testArr[indexPath.item])
    return size
  }
}
