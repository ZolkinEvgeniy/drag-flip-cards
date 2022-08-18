//
//  MoveViewAnimator.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 01.07.2022.
//

import UIKit
import Combine

class MoveViewAnimator: ViewAnimator {
  private struct Constants {
    static let distanceToTakeAction: CGFloat = 150//UIScreen.main.bounds.size.height / 5 // Distance required for the cell to go off the screen.
    static let animationDuration: TimeInterval = 0.3 // Duration of the Animation when Swiping Up/Down.
  }
  
  weak var frontView: UIView?
  
  var distanceMax: CGFloat = 0
  private var frontContainerViewCenterY: CGFloat {
    set {
      frontView?.transform.ty = newValue
    } get {
      return frontView?.transform.ty ?? 0
    }
  }
  private lazy var frontContainerViewInitialCenterY = self.frontContainerViewCenterY
  
  private var distance: CGFloat = 0
  private var canSendCompletion = true

  init(frontView: UIView, maxDistance: CGFloat) {
    self.frontView = frontView
    self.distanceMax = maxDistance
    super.init()
    _ = frontContainerViewInitialCenterY
  }
  
  private var anim: UIViewPropertyAnimator?
  
  func createAnimation() {
    canSendCompletion = true
    anim = UIViewPropertyAnimator(duration: Constants.animationDuration, curve: .easeInOut)
    anim?.addAnimations { [weak self] in
      guard let self = self else {return}
      self.frontContainerViewCenterY = self.distanceMax
    }
    anim?.addCompletion { [weak self] animPos in
      guard let self = self else {return}
      if self.canSendCompletion {
        self.onAction.send(.ended)
      }
      self.anim = nil
    }
  }

  func start() {
    createAnimation()
  }
  
  func change(offset: CGPoint) {
    var fraction: CGFloat = 0
    // Check if direction is correct
    if offset.y * distanceMax > 0 {
      fraction = offset.y / distanceMax
    }
    distance = offset.y
    
    anim?.fractionComplete = fraction
  }
  
  func finish() {
    if distance * distanceMax < 0 { return }
    if abs(distance) > Constants.distanceToTakeAction {
      moveTargetViewUp()
    } else {
      moveTargetViewToInitialPoint()
    }    
  }
  
  func reset() {
    moveTargetViewToInitialPoint()
  }
  
  func moveTargetViewToInitialPoint() {
    anim?.isReversed = true
    anim?.startAnimation()
    self.onAction.send(.canceled)
    canSendCompletion = false
  }
  
  func moveTargetViewUp() {
    anim?.startAnimation()
    self.onAction.send(.began)
  }
  
}

