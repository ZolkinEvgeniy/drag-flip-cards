//
//  CardFinishCell.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 01.07.2022.
//

import UIKit
import Combine

class CardFinishCell: CardCollectionViewCell {
  weak var viewModel: CardsViewModel!
  weak var centerView: UIView!
  weak var firstView: UIView!
  
  var onLaunchNext: (() -> Void)?
  
  weak private var firstContentStack: UIStackView!
  private var centerImage: UIImageView!
  private var statsView: CardStatsView!
  private weak var firstCounter: UICounterLabel!
  private weak var secondCounter: UICounterLabel!
  
  private var subscriptions = Set<AnyCancellable>()
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  func configure(viewModel: CardsViewModel) {
    self.viewModel = viewModel
  }
  
  func present() {
    let learned = viewModel.items.filter { $0.cardState == .remember}.count
    let unlearned = viewModel.items.filter { $0.cardState == .learn}.count
    
    statsView.setup(first: learned, second: unlearned, animated: true)
    
    if learned > 0 {
      firstCounter.superview!.isHidden = false
      firstCounter.countFrom(0, to: CGFloat(learned), withDuration: 1.0)
    } else {
      firstCounter.superview!.isHidden = true
    }
    if unlearned > 0 {
      secondCounter.superview!.isHidden = false
      secondCounter.countFrom(0, to: CGFloat(unlearned), withDuration: 1.0)
    } else {
      secondCounter.superview!.isHidden = true
    }
  }
  
  override func createContent() {
    
    let centerView = UIView()
    centerView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(centerView)
    self.centerView = centerView
    
    _ = createInnerView()
    
    setConstraints(isRegular: isRegular, views: [centerView])
    
    let w: CGFloat = 271
    let statsView = CardStatsView(frame:.zero)
    self.statsView = statsView
    statsView.translatesAutoresizingMaskIntoConstraints = false
    centerView.addSubview(statsView)
    NSLayoutConstraint.activate([
      statsView.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
      statsView.centerYAnchor.constraint(equalTo: centerView.centerYAnchor),
      statsView.widthAnchor.constraint(equalToConstant: w),
      statsView.heightAnchor.constraint(equalToConstant: w)
    ])

    createLabels()
  }
  
  private func createInnerView() -> UIView {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    centerView.addSubview(v)
    v.backgroundColor = .systemBlue
    v.layer.cornerRadius = 12
    v.setShadow()
    NSLayoutConstraint.activate([
      v.leadingAnchor.constraint(equalTo: centerView.leadingAnchor, constant: 0),
      v.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 0),
      v.trailingAnchor.constraint(equalTo: centerView.trailingAnchor, constant: 0),
      v.bottomAnchor.constraint(equalTo: centerView.bottomAnchor, constant: 0)
    ])

    return v
  }
  
  private func createLabels() {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 8
    
    stack.translatesAutoresizingMaskIntoConstraints = false
    centerView.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: centerView.centerYAnchor),
    ])
    
    firstCounter = createLabelView(color: .systemGreen, on: stack)
    firstCounter.format = "+%d"
    secondCounter = createLabelView(color: .systemRed, on: stack)
    secondCounter.format = "-%d"
  }
  
  private func createLabelView(color: UIColor, on stackView: UIStackView) -> UICounterLabel {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.backgroundColor = color
    v.layer.cornerRadius = 8
    
    let label = UICounterLabel(method: .UILabelCountingMethodEaseInOut, duration: 3)
    label.font = UIFont.systemFont(ofSize: 24)
    label.translatesAutoresizingMaskIntoConstraints = false
    v.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: v.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: v.centerYAnchor),
      v.widthAnchor.constraint(equalTo: label.widthAnchor, constant: 20),
      v.heightAnchor.constraint(equalTo: label.heightAnchor, constant: 16)
    ])
    label.textColor = .label
    label.numberOfLines = 0
    label.textAlignment = .center
    
    stackView.addArrangedSubview(v)
    
    return label
  }
  
  @objc func launchNextOrExit() {
    onLaunchNext?()
  }
}



extension UIImage {
  static func learnStatsImage(learned: Int, unlearned: Int) -> UIImage {
    let frame = CGRect(x: 0, y: 0, width: 271, height: 271)
    let radiusBig: CGFloat = frame.width * 0.5
    let radiusSmall: CGFloat = frame.width * 0.3
    let multiOffset: CGFloat = learned > 0 && unlearned > 0 ? 1 : 0
    let angleOffsetBig: CGFloat = 2.0 / radiusBig * multiOffset
    let angleOffsetSmall: CGFloat = 2.0 / radiusSmall * multiOffset
    
    let all = learned + unlearned
    let learnedAngle: CGFloat = CGFloat(learned) / CGFloat(all) * .pi*2
    let unlearnedAngle: CGFloat = .pi*2 - learnedAngle
    
    let renderer = UIGraphicsImageRenderer(size: frame.size)
    
    let img = renderer.image { ctx in
      let x: CGFloat = frame.width/2
      let y: CGFloat = frame.height/2
      
      if learned > 0 {
        ctx.cgContext.setFillColor(UIColor.systemGreen.cgColor)
        ctx.cgContext.addArc(center: CGPoint(x: x, y: y), radius: radiusSmall, startAngle: -.pi/2 + angleOffsetSmall, endAngle: -.pi/2 + learnedAngle - angleOffsetSmall, clockwise: false)
        ctx.cgContext.addArc(center: CGPoint(x: x, y: y), radius: radiusBig, startAngle: -.pi/2 + learnedAngle - angleOffsetBig, endAngle: -.pi/2 + angleOffsetBig, clockwise: true)
        
        ctx.cgContext.drawPath(using: .fill)
      }
      
      if unlearned > 0 {
        ctx.cgContext.setFillColor(UIColor.systemRed.cgColor)
        
        ctx.cgContext.addArc(center: CGPoint(x: x, y: y), radius: radiusSmall, startAngle: -.pi/2 - angleOffsetSmall, endAngle: -.pi/2 - unlearnedAngle + angleOffsetSmall, clockwise: true)
        ctx.cgContext.addArc(center: CGPoint(x: x, y: y), radius: radiusBig, startAngle: -.pi/2 - unlearnedAngle + angleOffsetBig, endAngle: -.pi/2 - angleOffsetBig, clockwise: false)
        
        ctx.cgContext.drawPath(using: .fill)
      }
    }
    return img
  }
}



class CardStatsView: UIView {
  var duration: TimeInterval = 1.0
  private(set) var firstValue: Int = 0
  private(set) var secondValue: Int = 0
  private weak var firstProgressView: CircularProgressView!
  private weak var secondProgressView: CircularProgressView!
  private weak var linesView: CircleWatchLines!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    initialize()
  }
  
  func initialize() {
    self.backgroundColor = .clear
    
    let lineWidth: CGFloat = 56
    let padding = lineWidth / 2
    
    let cp1 = CircularProgressView(frame: .zero, isReverse: false)
    self.firstProgressView = cp1
    cp1.lineWidth = lineWidth
    cp1.trackColor = UIColor.clear
    cp1.progressColor = .systemGreen
    cp1.backgroundColor = .clear
    self.addSubview(cp1)
    cp1.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      cp1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
      cp1.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
      cp1.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
      cp1.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding)
    ])
    
    let cp2 = CircularProgressView(frame: .zero, isReverse: true)
    self.secondProgressView = cp2
    cp2.lineWidth = lineWidth
    cp2.trackColor = UIColor.clear
    cp2.progressColor = .systemRed
    cp2.backgroundColor = .clear
    self.addSubview(cp2)
    cp2.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      cp2.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
      cp2.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
      cp2.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
      cp2.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding)
    ])
    
    setup()
  }
  
  func setup(first: Int = 0, second: Int = 0,
             animated: Bool = false) {
    self.firstValue = first
    self.secondValue = second
    
    if animated {
      animateShape()
    } else {
      changeShape()
    }
  }
  
  private func changeShape() {
    
  }
  
  private func animateShape() {
    let all = firstValue + secondValue
    let learnedValue: CGFloat = CGFloat(firstValue) / CGFloat(all)
    let unlearnedValue: CGFloat = CGFloat(secondValue) / CGFloat(all)
    
    firstProgressView.startValue = 0
    secondProgressView.startValue = 0
    firstProgressView.setProgressWithAnimation(duration: duration, value: learnedValue)
    secondProgressView.setProgressWithAnimation(duration: duration, value: unlearnedValue)
  }
  
}

class CircleWatchLines: UIView {
  var firstValue: Int = 0
  var secondValue: Int = 0
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    initialize()
  }
  
  func initialize() {
    self.backgroundColor = .clear
    
  }
  
  func setValues(first: Int, second: Int) {
    self.firstValue = first
    self.secondValue = second
    setNeedsDisplay()
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard let context = UIGraphicsGetCurrentContext() else {return}
    
    let all = firstValue + secondValue
    let angle: CGFloat = CGFloat(firstValue) / CGFloat(all) * .pi*2 - .pi/2
    
    let x = self.bounds.width / 2.0
    let y = self.bounds.height / 2.0
    let radius = x
    
    context.saveGState()
    let path = CGMutablePath()
    path.move(to: CGPoint(x: x, y: y))
    path.addLine(to: CGPoint(x: x, y: 0))
    
    let x2 = x + radius * cos(angle)
    let y2 = y + radius * sin(angle)
    path.move(to: CGPoint(x: x, y: y))
    path.addLine(to: CGPoint(x: x2, y: y2))
    context.addPath(path)
    context.setStrokeColor(UIColor.systemBackground.cgColor)
    context.setLineWidth(4)
    context.drawPath(using: CGPathDrawingMode.stroke)
    context.restoreGState()    
  }
}

