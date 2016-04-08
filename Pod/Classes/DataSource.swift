//
//  ChartDataSource.swift
//  MRLCircleChart
//
//  Created by Marek Lisik on 27/03/16.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

public class DataSource<Item: ChartValue> {

  public var maxValue: UInt
  public var numberOfItems: Int {
    return items.count
  }
  
  public required init(items: [Item], maxValue: UInt) {
    self.items = items
    self.maxValue = maxValue
  }
  
  private var items: [Item]
}

extension DataSource {
  
  func item(index: Int) -> Item? {
    guard index < items.count
          && index >= 0 else {
      return nil
    }
    return items[index]
  }

  func indexOf(item: Item) -> Int {
    guard let index = items.indexOf( { (itemToCheck: Item) -> Bool in
      return itemToCheck == item
    }) else {
      return NSNotFound
    }
    return index
  }
  
  func startAngle(index: Int) -> CGFloat {
    let slice = items[0..<index]
    let angle = slice.enumerate().reduce(0) { (sum, next) -> CGFloat in
      return sum + arcAngle(next.0)
    }
    return angle
  }
  
  func endAngle(index: Int) -> CGFloat {
    return startAngle(index) + arcAngle(index) + 0.01 // Extends endAngle to avoid unsighlty gaps between segments that are caused by antialiasing
  }
  
  func arcAngle(index: Int) -> CGFloat {
    guard let segment = item(index) else {
      return 0
    }
    let angle = Double(segment.value) / Double(totalValue()) * 2 * M_PI
    return CGFloat(angle)
  }
  
  func totalValue() -> UInt {
    let value = items.reduce(0) { (sum, next) -> UInt in
      return sum + next.value
    }
    return value
  }
}


