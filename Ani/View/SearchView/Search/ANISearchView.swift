//
//  UserSearchView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase
import NVActivityIndicatorView
import InstantSearchClient

protocol ANISearchViewDelegate {
  func searchViewDidScroll(scrollY: CGFloat)
}

enum SearchCategory: String {
  case user = "ユーザー";
  case story = "ストリー";
  case qna = "質問";
}

class ANISearchView: UIView {
  
  private weak var tableView: UITableView?
  
  private var searchUsers = [FirebaseUser]()
  private var searchStories = [FirebaseStory]()
  private var searchQnas = [FirebaseQna]()
  
  var selectedCategory: SearchCategory = .user {
    didSet {
      search(category: selectedCategory, searchText: searchText)
    }
  }
  
  var searchText: String = "" {
    didSet {
      search(category: selectedCategory, searchText: searchText)
    }
  }
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var delegate: ANISearchViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupNotifications()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //tableView
    let tableView = UITableView()
    tableView.separatorStyle = .none
    let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT
    tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    tableView.backgroundColor = .white
    tableView.alpha = 0.0
    let userId = NSStringFromClass(ANIUserSearchViewCell.self)
    tableView.register(ANIUserSearchViewCell.self, forCellReuseIdentifier: userId)
    let storyId = NSStringFromClass(ANIStoryViewCell.self)
    tableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyId)
    let supportCellId = NSStringFromClass(ANISupportViewCell.self)
    tableView.register(ANISupportViewCell.self, forCellReuseIdentifier: supportCellId)
    let qnaId = NSStringFromClass(ANIQnaViewCell.self)
    tableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: qnaId)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.alpha = 0.0
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.tableView = tableView
    
    //activityIndicatorView
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: ANIColor.green, padding: 0)
    addSubview(activityIndicatorView)
    activityIndicatorView.width(40.0)
    activityIndicatorView.height(40.0)
    activityIndicatorView.centerInSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
  
  private func setupNotifications() {
    ANINotificationManager.receive(searchTabTapped: self, selector: #selector(scrollToTop))
  }
  
  @objc private func scrollToTop() {
    guard let userTableView = tableView,
          !searchUsers.isEmpty else { return }
    
    userTableView.scrollToRow(at: [0, 0], at: .top, animated: true)
  }
}

//MARK: UITableViewDataSource
extension ANISearchView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch selectedCategory {
    case .user:
      return searchUsers.count
    case .story:
      return searchStories.count
    case .qna:
      return searchQnas.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch selectedCategory {
    case .user:
      let userId = NSStringFromClass(ANIUserSearchViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: userId, for: indexPath) as! ANIUserSearchViewCell
      
      cell.user = searchUsers[indexPath.row]
      
      return cell
    case .story:
      if !searchStories.isEmpty {
        if searchStories[indexPath.row].recruitId != nil {
          let supportCellId = NSStringFromClass(ANISupportViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: supportCellId, for: indexPath) as! ANISupportViewCell
          
          cell.story = searchStories[indexPath.row]
          
          return cell
        } else {
          let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
          
          cell.story = searchStories[indexPath.row]
          
          return cell
        }
      } else {
        return UITableViewCell()
      }
    case .qna:
      let qnaId = NSStringFromClass(ANIQnaViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: qnaId, for: indexPath) as! ANIQnaViewCell
      
      cell.qna = searchQnas[indexPath.row]
      
      return cell
    }
  }
}

//MARK: UITableViewDelegate
extension ANISearchView: UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    ANINotificationManager.postViewScrolled()
    
    //navigation bar animation
    let scrollY = scrollView.contentOffset.y
    self.delegate?.searchViewDidScroll(scrollY: scrollY)
  }
}

//MARK: search
extension ANISearchView {
  private func search(category: SearchCategory, searchText: String) {
    guard let activityIndicatorView = self.activityIndicatorView else { return }
    
    //TODO: algolia add index ANI-stories, ANI-qnas
    let index = ANISessionManager.shared.client.index(withName: "ANI-users")
    
    if !searchUsers.isEmpty {
      searchUsers.removeAll()
    }
    
    activityIndicatorView.startAnimating()
    
    DispatchQueue.global().async {
      index.search(Query(query: searchText), completionHandler: { (content, error) -> Void in
        if let content = content, let hits = content["hits"] as? [AnyObject] {
          for hit in hits {
            guard let hitDic = hit as? [String: AnyObject],
                  let currenUserUid = ANISessionManager.shared.currentUserUid else { return }
            
            do {
              switch category {
              case .user:
                let user = try FirebaseDecoder().decode(FirebaseUser.self, from: hitDic)
                
                if user.uid != currenUserUid {
                  self.searchUsers.append(user)
                }
              case .story:
                let story = try FirebaseDecoder().decode(FirebaseStory.self, from: hitDic)
                
                self.searchStories.append(story)
              case .qna:
                let qna = try FirebaseDecoder().decode(FirebaseQna.self, from: hitDic)
                
                self.searchQnas.append(qna)
              }
              
              DispatchQueue.main.async {
                guard let tableView = self.tableView else { return }
                
                activityIndicatorView.stopAnimating()
                
                tableView.reloadData()
                
                UIView.animate(withDuration: 0.2, animations: {
                  tableView.alpha = 1.0
                })
              }
            } catch let error {
              guard let tableView = self.tableView else { return }
              
              tableView.reloadData()

              print(error)
              
              activityIndicatorView.stopAnimating()
            }
          }
        } else if let error = error {
          print("error: \(error)")
          
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
}
