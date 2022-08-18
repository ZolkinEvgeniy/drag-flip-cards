//
//  CardViewCell.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 01.07.2022.
//

import UIKit
import Combine

class CardViewCell: CardCollectionViewCell {
  var viewModel: CardViewModel!
  var onNextCard: ((CardViewCell) -> Void)?
  var onLastCard: (() -> Void)?
  var onShowTermDetails: ((TermEntity) -> Void)?
  
  weak var centerView: UIView!
  weak var firstView: UIView!
  weak var secondView: UIView!
  weak private var firstLabel: UILabel!
  weak private var secondLabel: UILabel!
  private var moveAnimator: MoveViewAnimator!
  private var rotateAnimator: FlipViewAnimator!
  
  private var isDragging: Bool = false
  private var dragDistanceY: CGFloat = 0
  
  private var subscriptions = Set<AnyCancellable>()
  
  lazy var pan: UIPanGestureRecognizer = {
    let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    pan.delegate = self
    return pan
  }()
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  // MARK: Methods
  
  override func initialize() {
    super.initialize()
    addGestureRecognizer(pan)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if let prev = previousTraitCollection {
      if prev.horizontalSizeClass != traitCollection.horizontalSizeClass {
        setConstraints(isRegular: isRegular)
      }
    } else {
      setConstraints(isRegular: isRegular)
    }
  }
  
  //MARK: CREATE
  
  override func createContent() {
    
    let centerView = UIView()
    centerView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(centerView)
    self.centerView = centerView
    
    createSecondView()
    createFirstView()
    
    let maxY = contentView.bounds.height / 2 + centerView.bounds.height / 2 - 10
    moveAnimator = MoveViewAnimator(frontView: centerView, maxDistance: -maxY)
    rotateAnimator = FlipViewAnimator(frontView: firstView, backView: secondView)
    
    setConstraints(isRegular: isRegular)
    
    moveAnimator.onAction.sink { [unowned self] action in
      self.handleMoving(action: action)
    }.store(in: &subscriptions)
    
    rotateAnimator.onAction.sink { [unowned self] action in
      self.handleFlipping(action: action)
    }.store(in: &subscriptions)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    contentView.addGestureRecognizer(tapGesture)
  }
  
  private func createFirstView() {
    firstView = createInnerView()
    firstView.layer.isDoubleSided = false

    self.firstLabel = createViewLabel(on: firstView, text: "", alignCenter: true)
  }
  
  private func createSecondView() {
    secondView = createInnerView()
    secondView.backgroundColor = .systemRed
    
    self.secondLabel = createViewLabel(on: secondView, text: "", alignCenter: true)
    self.secondLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
  }
  
  private func createInnerView() -> UIView {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    centerView.addSubview(v)
    v.layer.cornerRadius = 12
    v.setShadow()
    NSLayoutConstraint.activate([
      v.leadingAnchor.constraint(equalTo: centerView.leadingAnchor, constant: 0),
      v.trailingAnchor.constraint(equalTo: centerView.trailingAnchor, constant: 0),
      v.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 0),
      v.bottomAnchor.constraint(equalTo: centerView.bottomAnchor, constant: 0),
    ])

    return v
  }
  
  private func createViewLabel(on parent: UIView, text: String, alignCenter: Bool) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 25)
    label.textColor = .label
    label.text = text
    label.numberOfLines = 0
    label.textAlignment = alignCenter ? .center : .left
    parent.addSubview(label)
    
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 10),
      label.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: 10),
      label.topAnchor.constraint(equalTo: parent.topAnchor, constant: 5),
      label.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: 5),
    ])
    
    return label
  }
  
  //MARK: Methods
  
  func configure(viewModel: CardViewModel) {
    self.viewModel = viewModel
    if viewModel.cardState == .none {
      viewModel.isShown = true
    }
    
    firstLabel.text = viewModel.termEntity.name
    secondLabel.text = viewModel.termEntity.details
  }
  
  override func updateContent(isCurrent: Bool) {
    centerView.transform = .identity
    if !isCurrent {
      switch viewModel.cardState {
      case .learn, .remember:
        firstView.isHidden = false
        firstView.layer.transform = CATransform3DIdentity
        secondView.layer.transform = CATransform3DIdentity
      case .none:
        firstView.isHidden = false
        firstView.layer.transform = CATransform3DIdentity
        secondView.layer.transform = CATransform3DIdentity
      }
      rotateAnimator.isReverse = false
    }
    updateState()
  }
  
  private func updateState() {
    switch viewModel.cardState {
    case .remember:
      firstView.backgroundColor = .systemGreen
    case .learn:
      firstView.backgroundColor = .systemRed
    default:
      firstView.backgroundColor = .systemBrown
    }
  }
  
  func setConstraints(isRegular: Bool) {
    let vv: [UIView] = [centerView]
    setConstraints(isRegular: isRegular, views: vv)
    let maxY = contentView.bounds.height / 2 + centerView.bounds.height / 2 - 10
    moveAnimator.distanceMax = -maxY
  }
  
  @objc private func handleTap() {
    rotateAnimator.launchAnimation(direction: .horizontal)
  }
  
  private func handleMoving(action: ViewAnimatorAction) {
    switch action {
    case .ended:
      if viewModel.changeState(.remember) {
        updateState()
      }
      onNextCard?(self)
    default:
      break
    }
  }
  
  private func handleFlipping(action: ViewAnimatorAction) {
    switch action {
    case .ended:
      if viewModel.changeState(.learn) {
        updateState()
      }
    default:
      break
    }
  }
  
  @objc fileprivate func handlePanGesture(_ sender: UIPanGestureRecognizer) {
    let dist = sender.translation(in: contentView)
    switch sender.state {
    case .began:
      moveAnimator.start()
      rotateAnimator.createAnimation(direction: .vertical)
    case .changed:
      moveAnimator.change(offset: dist)
      rotateAnimator.change(offset: dist)
    case .ended:
      moveAnimator.finish()
      rotateAnimator.finish()
    default:
      break
    }
  }
}



// MARK: UIGestureRecognizerDelegate

extension CardViewCell: UIGestureRecognizerDelegate {
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer,
       panGestureRecognizer == pan {
      let translation = panGestureRecognizer.translation(in: superview!)
      if abs(translation.y) < abs(translation.x) {
        return false
      }
    }
    return true
  }
}
