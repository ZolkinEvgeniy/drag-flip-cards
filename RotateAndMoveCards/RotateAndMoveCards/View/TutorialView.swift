//
//  TutorialView.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 08.07.2022.
//

import UIKit

class TutorialView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func initialize() {
    self.backgroundColor = .systemGray3//.withAlphaComponent(0.7)
    
    var views = [UIView]()
    let arrowUpImage = createArrowView(imageName: "chevron.up", width: 100, height: 50, x: 0, y: -150)
    views.append(arrowUpImage)
    let arrowDownImage = createArrowView(imageName: "chevron.down", width: 100, height: 50, x: 0, y: 150)
    views.append(arrowDownImage)
    let arrowLeftImage = createArrowView(imageName: "chevron.left", width: 50, height: 100, x: -100, y: -0)
    views.append(arrowLeftImage)
    let arrowRightImage = createArrowView(imageName: "chevron.right", width: 50, height: 100, x: 100, y: 0)
    views.append(arrowRightImage)
    let centerImage = createArrowView(imageName: "circle", width: 100, height: 100, x: 0, y: 0)
    views.append(centerImage)
    _ = createLabel(text: "SWIPE UP", x: 0, y: -300)
    _ = createLabel(text: "SWIPE DOWN", x: 0, y: 300)
    _ = createLabel(text: "TAP", x: 0, y: 0)

    
    UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.calculationModeCubic, .repeat]) {
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
        arrowUpImage.transform = CGAffineTransform(translationX: 0, y: -100)
        arrowDownImage.transform = CGAffineTransform(translationX: 0, y: 100)
        arrowLeftImage.transform = CGAffineTransform(translationX: -50, y: 0)
        arrowRightImage.transform = CGAffineTransform(translationX: 50, y: 0)
      }
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
        views.forEach { $0.alpha = 1 }
      }
      UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
        views.forEach { $0.alpha = 0 }
      }

    } 
   
    let gesture = UITapGestureRecognizer(target: self, action: #selector(tap))
    self.addGestureRecognizer(gesture)
  }
  
  func createArrowView(imageName: String, width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat) -> UIView {
    let arrowImage = UIImageView(image: UIImage(systemName: imageName))
    arrowImage.translatesAutoresizingMaskIntoConstraints = false
    arrowImage.tintColor = .white
    self.addSubview(arrowImage)
    
    
    NSLayoutConstraint.activate([
      arrowImage.widthAnchor.constraint(equalToConstant: width),
      arrowImage.heightAnchor.constraint(equalToConstant: height),
      arrowImage.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: x),
      arrowImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: y),
    ])
    
    arrowImage.alpha = 0
    return arrowImage
  }
  
  func createLabel(text: String, x: CGFloat, y: CGFloat) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .white
    label.text = text
    label.font = UIFont.systemFont(ofSize: 25)
    self.addSubview(label)
    
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: x),
      label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: y),
    ])
    
    return label
  }
  
  @objc func tap() {
    UIView.perform(.delete, on: [self], options: .curveLinear) {
      self.alpha = 0
    }

  }
}
