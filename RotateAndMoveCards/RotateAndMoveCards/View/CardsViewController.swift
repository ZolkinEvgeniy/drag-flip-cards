//
//  CardsViewController.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 01.07.2022.
//

import UIKit

class CardsViewController: UIViewController {
  
  var onClose: (() -> Void)?
  
  weak var contentView: UIView!
  weak var cardsView: CardsView!
  
  // MARK: Properties
  
  var viewModel: CardsViewModel = CardsViewModel()
  
  lazy var cardImageViewHeight: CGFloat = cardsView.frame.height * 0.45 //  45% is cell.imageView height constraint's multiplier
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createCardsView()
    createTutorial()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    cardsView.collectionViewLayout.invalidateLayout()
  }
  
  func createTutorial() {
    let v = TutorialView(frame: view.bounds)
    v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(v)
  }
  
  func createCardsView() {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 0

    let cardsView = CardsView(frame: view.bounds, collectionViewLayout: layout)
    self.cardsView = cardsView
    cardsView.dataSource = self
    cardsView.showsHorizontalScrollIndicator = false
    cardsView.decelerationRate = UIScrollView.DecelerationRate.fast
    cardsView.backgroundColor = nil// .themeOverlay
    cardsView.alwaysBounceHorizontal = true
    self.view.addSubview(cardsView)
    
    cardsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    // Register cell classes
    cardsView.register(CardViewCell.self, forCellWithReuseIdentifier: "CardViewCell")
    cardsView.register(CardFinishCell.self, forCellWithReuseIdentifier: "CardFinishCell")
  }
  
  // MARK: Methods
  
  func handleViewControllerDismiss() {
    let amountOfCells = cardsView.numberOfItems(inSection: 0)
    if amountOfCells == 0 { return }
    var indexPathesToDelete = [IndexPath]()
    for index in (1 ..< amountOfCells).reversed() {
      indexPathesToDelete.append(IndexPath(row: index, section: 0))
    }
    cardsView.deleteItems(at: indexPathesToDelete)
  }
  
}

// MARK: CollectionView DataSource

extension CardsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.itemCount + 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.row == viewModel.itemCount {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardFinishCell", for: indexPath) as! CardFinishCell
      cell.configure(viewModel: viewModel)
      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardViewCell", for: indexPath) as! CardViewCell
      let vm = viewModel.items[indexPath.row]
      cell.configure(viewModel: vm)
      cell.updateContent(isCurrent: indexPath.row == cardsView.currentPageIndex)
      cell.onNextCard = { [unowned self] cell in
        self.cardsView.scrollToNextPage()
      }
      return cell
    }
  }
}
