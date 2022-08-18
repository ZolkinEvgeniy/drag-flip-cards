//
//  CardsViewModel.swift
//  RotateAndMoveCards
//
//  Created by Zolkin Evgeny on 01.07.2022.
//

import Combine

enum CardLearningMode: Int {
  case first
  case second
  case random
}

class CardsViewModel {
  var terms: [TermEntity]
  var items: [CardViewModel] = []
  
  var onRequestNextLearningPack: (() -> [TermEntity])?
  private var nextPackRequested = false
  
  init() {
    self.terms = [
      TermEntity(name: "Climb", details: "Вбираться\nПодъём\nВьюнок"),
      TermEntity(name: "Attempt", details: "Попытка\nПокушение\nПробовать"),
      TermEntity(name: "Misunderstanding", details: "Непонимание\nНедоразумение")
    ]
    self.items = terms.map { CardViewModel(model: $0) }
  }
  
  var itemCount: Int {
    return items.count
  }
  
  var unlearnedCount: Int {
    items.filter { $0.cardState == .none }.count
  }
  
  func removeItem(_ item: CardViewModel) -> Int? {
    guard let index = items.firstIndex(where: { $0 === item }) else {
      return nil
    }
    items.remove(at: index)
    return index
  }
}


class TermEntity {
  let name: String
  let details: String
  
  init(name: String, details: String) {
    self.name = name
    self.details = details
  }
}
