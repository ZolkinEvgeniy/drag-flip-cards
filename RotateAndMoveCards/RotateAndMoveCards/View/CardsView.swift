//
//  CardsView.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 01.07.2022.
//

import UIKit

class CardsView: UICollectionView {
  
  // MARK: Properties
  
  private(set) var currentPageIndex = 0
  var onAppearFinishCard: (() -> Bool)?
  
  // MARK: Methods
  
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
    initialise()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialise()
  }
  
  private func initialise() {
    decelerationRate = UIScrollView.DecelerationRate.fast
    isPagingEnabled = true
    delegate = self
  }
  
  func scrollToItem(at index: Int, animated: Bool = false) {
    if index < 0 || index > numberOfItems(inSection: 0) - 1 { return }
    scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    currentPageIndex = index
  }
  
  func scrollToCurrentItem() {
    scrollToItem(at: currentPageIndex)
  }
  
  func scrollToNextPage() {
    scrollToItem(at: currentPageIndex + 1, animated: true)
  }
  
  func scrollToPreviousPage() {
    scrollToItem(at: currentPageIndex - 1, animated: true)
  }
  
  func scrollToEnd() {
    scrollToItem(at: numberOfItems(inSection: 0) - 1, animated: true)
  }
  
  func reloadItem(at index: Int) {
    if index > numberOfItems(inSection: 0) { return }
    reloadItems(at: [IndexPath(row: index, section: 0)])
  }
  
  func removeItem(at index: Int) {
    if index > numberOfItems(inSection: 0) { return }
    deleteItems(at: [IndexPath(row: index, section: 0)])
    currentPageIndex = getVisibleCardIndexPath()?.row ?? 0
  }
  
  func getVisibleCardIndexPath() -> IndexPath? {
    let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    return indexPathForItem(at: visiblePoint)
  }
  
  func reset() {
    currentPageIndex = 0
  }
}


extension CardsView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let cell = cell as? CardCollectionViewCell {
      cell.updateContent(isCurrent: false)
    }
  }
  
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    let pageWidth = bounds.width
    pageWasChanged(pageNumber: Int(contentOffset.x / pageWidth))
  }
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let pageWidth = bounds.width
    pageWasChanged(pageNumber: Int(contentOffset.x / pageWidth))
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      let pageWidth = bounds.width
      pageWasChanged(pageNumber: Int(contentOffset.x / pageWidth))
    }
  }
  
  func pageWasChanged(pageNumber: Int) {
    currentPageIndex = pageNumber
    if let finishCard = self.cellForItem(at: IndexPath(row: currentPageIndex, section: 0)) as? CardFinishCell {
      finishCard.present()
    }
    
    if let currentCard = self.cellForItem(at: IndexPath(row: currentPageIndex, section: 0)) as? CardCollectionViewCell {
      currentCard.cellDidAppear()
    }
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    if let currentCard = self.cellForItem(at: IndexPath(row: currentPageIndex, section: 0)) as? CardCollectionViewCell {
      currentCard.cellWillBeginDragging()
    }
  }
}

extension CardsView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    return size
  }
  
}
