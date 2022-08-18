//
//  FlipViewAnimator.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 05.07.2022.
//

import UIKit
import Combine

class FlipViewAnimator: ViewAnimator {
  private struct Constants {
    static let distanceToTakeAction: CGFloat = 150//UIScreen.main.bounds.size.height / 5 // Distance required for the cell to go off the screen.
    static let animationDuration: TimeInterval = 0.5 // Duration of the Animation when Swiping Up/Down.
  }
  
  enum RotateDirection {
    case horizontal
    case vertical
  }
  
  weak var frontView: UIView?
  weak var backView: UIView?
  var isReverse: Bool = false
  var canSendCompletion = true
  
  private var originalPoint: CGPoint = .zero
  private var distancePoint: CGPoint = .zero
  
  init(frontView: UIView, backView: UIView?) {
    self.frontView = frontView
    self.backView = backView
  }
  
  private var anim: UIViewPropertyAnimator?
  
  func createAnimation(direction: RotateDirection) {
    canSendCompletion = true
    anim = UIViewPropertyAnimator(duration: Constants.animationDuration, curve: .easeInOut)
    anim?.addAnimations { [weak self] in
      guard let self = self else {return}
      let angle: CGFloat = .pi
      var tr = CATransform3DIdentity
      tr.m34 = -1.0/1000.0
      let x: CGFloat = 0
      let y: CGFloat = -1
      tr = self.isReverse ? CATransform3DIdentity : CATransform3DRotate(tr, angle, x, y, 0)
      self.frontView?.transform3D = tr
      self.backView?.transform3D = tr
    }
    anim?.addCompletion { [weak self] animPos in
      guard let self = self else {return}
      if self.canSendCompletion {
        self.onAction.send(.ended)
        self.isReverse.toggle()
      }
      self.anim = nil
    }
  }
  
  func change(offset: CGPoint) {
    distancePoint = offset
    if distancePoint.y > 0 {
      let speed: CGFloat = 100
      var tr = CATransform3DIdentity
      tr.m34 = -1.0/1000.0
      let angle: CGFloat = max(0, min(.pi, distancePoint.y / speed))
      let fr: CGFloat = angle / .pi
      anim?.fractionComplete = fr
    }
  }
  
  private func setTransform(to view: UIView?, angle: CGFloat, clockwise: Bool) {
    guard let view = view else {return}
    var tr = CATransform3DIdentity
    tr.m34 = -1/1000.0
    tr = CATransform3DRotate(tr, angle, 0, 1, 0)
    view.transform3D = tr
  }
  
  func finish() {
    if distancePoint.y <= 0 { return }
    if distancePoint.y > Constants.distanceToTakeAction {
      rotateTargetView()
    } else {
      moveTargetViewToInitialPoint()
    }
  }
  
  func launchAnimation(direction: RotateDirection) {
    createAnimation(direction: direction)
    rotateTargetView()
  }
  
  /// 'percent' is a CGFloat value from 0 to 1.
  func rotationChanged(on percent: CGFloat) {
    self.onAction.send(.changed(persent: percent))
  }
  
  func moveTargetViewToInitialPoint() {
    if distancePoint.y == 0 { return }
    
    anim?.isReversed = true
    anim?.startAnimation()
    self.onAction.send(.canceled)
    canSendCompletion = false
  }
  
  func rotateTargetView() {
    anim?.startAnimation()
    self.onAction.send(.began)
  }
}

