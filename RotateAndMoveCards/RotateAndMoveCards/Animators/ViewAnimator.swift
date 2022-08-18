//
//  ViewAnimator.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 01.07.2022.
//

import UIKit
import Combine

class ViewAnimator {
  let onAction = PassthroughSubject<ViewAnimatorAction,Never>()
}


enum ViewAnimatorAction {
  case began
  case ended
  case canceled
  case changed(persent: CGFloat)
}
