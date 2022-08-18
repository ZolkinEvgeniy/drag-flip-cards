//
//  CardCollectionViewCell.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 01.07.2022.
//

import UIKit
import Combine

class CardCollectionViewCell: UICollectionViewCell {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = nil
    initialize()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Methods
  
  func initialize() {
    createContent()
  }

  // MARK: Methods
  
  func configure() {}
  func updateContent(isCurrent: Bool) {}
  func createContent() {}
  func cellDidAppear() {}
  func cellWillDisappear() {}
  func cellWillBeginDragging() {}
  
  func setConstraints(isRegular: Bool, views: [UIView]) {
    for v in views {
      v.removeFromSuperview()
      contentView.addSubview(v)
      if isRegular {
        NSLayoutConstraint.activate([
          v.widthAnchor.constraint(equalToConstant: 540),
          v.heightAnchor.constraint(equalToConstant: 660),
          v.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
          v.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
      } else {
        NSLayoutConstraint.activate([
          v.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8),
          v.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -8),
          v.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
          v.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
        ])
      }
      v.layoutIfNeeded()
    }
  }
}


