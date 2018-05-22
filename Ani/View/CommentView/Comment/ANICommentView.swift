//
//  CommentView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/21.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANICommentView: UIView {
  
  private weak var commentTableView: UITableView?
  
  var commentMode: CommentMode?
  
  var story: Story?
  var qna: Qna?
  
  private var originalScrollY: CGFloat = 0.0
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //commentTableView
    let commentTableView = UITableView()
    commentTableView.separatorStyle = .none
    let contentCellId = NSStringFromClass(ANICommentContentCell.self)
    commentTableView.register(ANICommentContentCell.self, forCellReuseIdentifier: contentCellId)
    let commentCellId = NSStringFromClass(ANICommentCell.self)
    commentTableView.register(ANICommentCell.self, forCellReuseIdentifier: commentCellId)
    commentTableView.dataSource = self
    commentTableView.delegate = self
    addSubview(commentTableView)
    commentTableView.edgesToSuperview()
    self.commentTableView = commentTableView
  }
}

//MARK: UITableViewDataSource
extension ANICommentView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let commentMode = self.commentMode else { return 0 }
    
    switch commentMode {
    case .story:
      if let story = self.story, let comments = story.comments {
        return comments.count + 1
      } else {
        return 0
      }
    case .qna:
      if let qna = self.qna, let comments = qna.comments {
        return comments.count + 1
      } else {
        return 0
      }
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let commentMode = self.commentMode else { return UITableViewCell() }

    if indexPath.row == 0 {
      let contentCellId = NSStringFromClass(ANICommentContentCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: contentCellId, for: indexPath) as! ANICommentContentCell
      
      switch commentMode {
      case .story:
          if let story = self.story {
            cell.content = story.story
          }
      case .qna:
        if let qna = self.qna {
          cell.content = qna.qna
        }
      }
      
      return cell
    } else {
      let commentCellId = NSStringFromClass(ANICommentCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! ANICommentCell
      
      switch commentMode {
      case .story:
        if let story = self.story, let comments = story.comments {
          cell.comment = comments[indexPath.row - 1]
        }
      case .qna:
        if let qna = self.qna, let comments = qna.comments {
          cell.comment = comments[indexPath.row - 1]
        }
      }

      return cell
    }
  }
}

extension ANICommentView: UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let scrollY = scrollView.contentOffset.y
    if (originalScrollY - scrollY) > 50 {
      ANINotificationManager.postViewScrolled()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    originalScrollY = scrollView.contentOffset.y
  }
}
