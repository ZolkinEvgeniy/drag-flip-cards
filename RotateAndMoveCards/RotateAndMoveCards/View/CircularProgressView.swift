//
//  CircularProgressView.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 03.07.2022.
//

import UIKit

class CircularProgressView: UIView {
  
  var progressValue: CGFloat = 0
  var isReverse: Bool = false
  
  fileprivate var progressLayer = CAShapeLayer()
  fileprivate var trackLayer = CAShapeLayer()
  
  init(frame: CGRect, isReverse: Bool) {
    self.isReverse = isReverse
    super.init(frame: frame)
    createCircularPath()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    createCircularPath()
  }
  
  var progressColor = UIColor.white {
    didSet {
      progressLayer.strokeColor = progressColor.cgColor
    }
  }
  
  var trackColor = UIColor.white {
    didSet {
      trackLayer.strokeColor = trackColor.cgColor
    }
  }
  
  var lineWidth: CGFloat = 10 {
    didSet {
      trackLayer.lineWidth = lineWidth
      progressLayer.lineWidth = lineWidth
    }
  }
  
  var startValue: CGFloat = 0 {
    didSet {
      progressLayer.strokeStart = startValue
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    createCircularPath()
  }
  
  fileprivate func createCircularPath() {
    self.layer.cornerRadius = self.frame.size.width/2
    let circlePath = UIBezierPath(arcCenter: CGPoint(x: bounds.size.width/2, y: bounds.size.height/2), radius: (bounds.size.width - 1.5)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat((isReverse ? -2.5 : 1.5) * .pi), clockwise: !isReverse)
    trackLayer.path = circlePath.cgPath
    trackLayer.fillColor = UIColor.clear.cgColor
    trackLayer.strokeColor = trackColor.cgColor
    trackLayer.lineWidth = self.lineWidth
    trackLayer.strokeEnd = 1.0
    layer.addSublayer(trackLayer)
    
    progressLayer.path = circlePath.cgPath
    progressLayer.fillColor = UIColor.clear.cgColor
    progressLayer.strokeColor = progressColor.cgColor
    progressLayer.lineWidth = self.lineWidth
    progressLayer.strokeStart = startValue
    progressLayer.strokeEnd = progressValue
    layer.addSublayer(progressLayer)
  }
  
  func setProgressWithAnimation(duration: TimeInterval, value: CGFloat) {
    self.progressValue = value
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.duration = duration
    animation.fromValue = 0
    animation.toValue = value
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    progressLayer.strokeEnd = value
    progressLayer.add(animation, forKey: "animateprogress")
  }
}

