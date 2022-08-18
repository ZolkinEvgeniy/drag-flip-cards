//
//  Utils.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 03.07.2022.
//

import UIKit

extension UIView {
  var isRegular: Bool {
    return traitCollection.horizontalSizeClass == .regular
  }
  
  var isDarkMode: Bool {
    return traitCollection.userInterfaceStyle == .dark
  }
}

extension UIViewController {
  var isRegular: Bool {
    return traitCollection.horizontalSizeClass == .regular
  }
  
  var isDarkMode: Bool {
    return traitCollection.userInterfaceStyle == .dark
  }
}

extension UIPresentationController {
  var isRegular: Bool {
    self.traitCollection.horizontalSizeClass == .regular && self.traitCollection.verticalSizeClass == .regular
  }
}

// MARK: Shadow

extension UIView {
  func setShadow(radius: CGFloat? = nil,
                 color: UIColor = UIColor.systemGray6,
                 opacity: Float = 0.15,
                 offset: CGSize = .zero) {
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowRadius = radius != nil ? radius! : isRegular ? 32 : 8
    layer.shadowOffset = offset
  }
}
