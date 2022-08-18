//
//  CardViewModel.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 01.07.2022.
//

class CardViewModel {

  enum CardState {
    case none
    case learn
    case remember
  }
  
  struct RowContent {
    let text: String
    let centered: Bool
  }
  
  let termEntity: TermEntity
  var cardState: CardState = .none
  var isShown: Bool = false
  
  init(model: TermEntity) {
    self.termEntity = model
  }

  func getContent() -> [RowContent] {
    return [RowContent(text: termEntity.name, centered: true)]
  }
  
  /// Try change card state. Return true if state successfully changed
  func changeState(_ newState: CardState) -> Bool {
    cardState = newState
    return true
  }
}

