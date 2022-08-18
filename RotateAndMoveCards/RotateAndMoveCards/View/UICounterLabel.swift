//
//  UICounterLabel.swift
//

import UIKit
import QuartzCore

enum UILabelCountingMethod {
  case UILabelCountingMethodEaseInOut
  case UILabelCountingMethodEaseIn
  case UILabelCountingMethodEaseOut
  case UILabelCountingMethodLinear
  case UILabelCountingMethodEaseInBounce
  case UILabelCountingMethodEaseOutBounce
}

let kUILabelCounterRate: CGFloat = 3

protocol UILabelCounter {
  func update(t: CGFloat) -> CGFloat
}

class UILabelCounterLinear: UILabelCounter {
  func update(t: CGFloat) -> CGFloat {
    return t
  }
}

class UILabelCounterEaseIn: UILabelCounter {
  func update(t: CGFloat) -> CGFloat {
    return pow(t, kUILabelCounterRate)
  }
}

class UILabelCounterEaseOut: UILabelCounter {
  func update(t: CGFloat) -> CGFloat {
    return 1.0 - pow((1.0 - t), kUILabelCounterRate)
  }
}

class UILabelCounterEaseInOut: UILabelCounter {
  func update(t: CGFloat) -> CGFloat {
    let t2 = t * 2
    if (t2 < 1) {
      return 0.5 * pow (t2, kUILabelCounterRate)
    } else {
      return 0.5 * (2.0 - pow(2.0 - t2, kUILabelCounterRate))
    }
  }
}

class UILabelCounterEaseInBounce: UILabelCounter {
  func update(t: CGFloat) -> CGFloat {
    if (t < 4.0 / 11.0) {
      return 1.0 - (pow(11.0 / 4.0, 2) * pow(Double(t), 2)) - t
    }
    
    if (t < 8.0 / 11.0) {
      return 1.0 - (3.0 / 4.0 + pow(11.0 / 4.0, 2) * pow(t - 6.0 / 11.0, 2)) - t
    }
    
    if (t < 10.0 / 11.0) {
      return 1.0 - (15.0 / 16.0 + pow(11.0 / 4.0, 2) * pow(t - 9.0 / 11.0, 2)) - t
    }
    
    return 1.0 - (63.0 / 64.0 + pow(11.0 / 4.0, 2) * pow(t - 21.0 / 22.0, 2)) - t
  }
}

class UILabelCounterEaseOutBounce: UILabelCounter {
  func update(t: CGFloat) -> CGFloat {
    if (t < 4.0 / 11.0) {
      return pow(11.0 / 4.0, 2) * pow(Double(t), 2)
    }
    
    if (t < 8.0 / 11.0) {
      return 3.0 / 4.0 + pow(11.0 / 4.0, 2) * pow(t - 6.0 / 11.0, 2)
    }
    
    if (t < 10.0 / 11.0) {
      return 15.0 / 16.0 + pow(11.0 / 4.0, 2) * pow(t - 9.0 / 11.0, 2)
    }
    
    return 63.0 / 64.0 + pow(11.0 / 4.0, 2) * pow(t - 21.0 / 22.0, 2)
  }
}

typealias UICountingLabelFormatBlock = (_ value: CGFloat) -> String
typealias UICountingLabelAttributedFormatBlock = (_ value: CGFloat) -> NSAttributedString

// MARK: - UICountingLabel

class UICounterLabel: UILabel {
  var startingValue: CGFloat = 0
  var destinationValue: CGFloat = 0
  var progress: TimeInterval = .zero
  var lastUpdate: TimeInterval = .zero
  var totalTime: TimeInterval = .zero
  var easingRate: CGFloat = 0
  
  var timer: CADisplayLink?
  var counter: UILabelCounter!
  
  var format: String?
  var method: UILabelCountingMethod
  var animationDuration: TimeInterval
  
  var formatBlock: UICountingLabelFormatBlock?
  var attributedFormatBlock: UICountingLabelAttributedFormatBlock?
  var completionBlock: (() -> Void)?
  
  init(method: UILabelCountingMethod, duration: Float) {
    self.method = method
    self.animationDuration = TimeInterval(duration)
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func countFrom(_ value: CGFloat, to endValue: CGFloat) {
    
    if (self.animationDuration == 0.0) {
      self.animationDuration = 2.0
    }
    
    self.countFrom(value, to:endValue, withDuration: self.animationDuration)
  }
  
  func countFrom(_ startValue: CGFloat, to endValue: CGFloat, withDuration duration: TimeInterval) {
    
    self.startingValue = startValue
    self.destinationValue = endValue
    
    // remove any (possible) old timers
    self.timer?.invalidate()
    self.timer = nil
    
    if(self.format == nil) {
      self.format = "%f"
    }
    if (duration == 0.0) {
      // No animation
      self.setTextValue(endValue)
      self.runCompletionBlock()
      return;
    }
    
    self.easingRate = 3.0
    self.progress = 0
    self.totalTime = duration
    self.lastUpdate = CACurrentMediaTime()
    
    switch self.method {
    case .UILabelCountingMethodLinear:
      self.counter = UILabelCounterLinear()
    case .UILabelCountingMethodEaseIn:
      self.counter = UILabelCounterEaseIn()
    case .UILabelCountingMethodEaseOut:
      self.counter = UILabelCounterEaseOut()
    case .UILabelCountingMethodEaseInOut:
      self.counter = UILabelCounterEaseInOut()
    case .UILabelCountingMethodEaseOutBounce:
      self.counter = UILabelCounterEaseOutBounce()
    case .UILabelCountingMethodEaseInBounce:
      self.counter = UILabelCounterEaseInBounce()
    }
    
    let timer = CADisplayLink(target: self, selector: #selector(updateValue))
    timer.preferredFramesPerSecond = 30
    timer.add(to: RunLoop.main, forMode: .default)
    timer.add(to: RunLoop.main, forMode: .tracking)
    self.timer = timer
  }
  
  func countFromCurrentValueTo(endValue: CGFloat) {
    self.countFrom(self.currentValue, to:endValue)
  }
  
  func countFromCurrentValueTo(endValue: CGFloat, withDuration duration: TimeInterval) {
    self.countFrom(self.currentValue, to:endValue, withDuration:duration)
  }
  
  func countFromZeroTo(endValue: CGFloat) {
    self.countFrom(0.0, to:endValue)
  }
  
  func countFromZeroTo(endValue: CGFloat, withDuration duration: TimeInterval) {
    self.countFrom(0.0, to:endValue, withDuration:duration)
  }
  
  @objc func updateValue(_ timer: Timer) {
    
    // update progress
    let now: TimeInterval = CACurrentMediaTime()
    self.progress += now - self.lastUpdate
    self.lastUpdate = now
    
    if (self.progress >= self.totalTime) {
      self.timer?.invalidate()
      self.timer = nil
      self.progress = self.totalTime
    }
    
    self.setTextValue(self.currentValue)
    
    if (self.progress == self.totalTime) {
      self.runCompletionBlock()
    }
  }
  
  func setTextValue(_ value: CGFloat) {
    if let attributedFormatBlock = self.attributedFormatBlock {
      self.attributedText = attributedFormatBlock(value)
    }
    else if let formatBlock = self.formatBlock {
      self.text = formatBlock(value)
    }
    else
    {
      if let format = self.format {
        // check if counting with ints - cast to int
        // regex based on IEEE printf specification: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html
        if format.range(of: "%[^fega]*[diouxc]", options: [.regularExpression, .caseInsensitive]) != nil {
          self.text = String(format: format, Int(value))
        }
        else
        {
          self.text = String(format: format, value)
        }
      }
    }
  }
  
  func setFormat(format: String) {
    self.format = format
    // update label with new format
    self.setTextValue(self.currentValue)
  }
  
  func runCompletionBlock() {
    
    if let block = self.completionBlock {
      self.completionBlock = nil
      block()
    }
  }
  
  var currentValue: CGFloat {
    
    if (self.progress >= self.totalTime) {
      return self.destinationValue
    }
    
    let percent = self.progress / self.totalTime
    let updateVal = self.counter.update(t: CGFloat(percent))
    return self.startingValue + (updateVal * (self.destinationValue - self.startingValue))
  }
}
