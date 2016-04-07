//
//  Chart.swift
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

import UIKit

public class ChartManager<T: ChartValue> {
  
  var dataSource: DataSource<T>
  var chart: Chart?
  
  required public init(dataSource dataSource: DataSource<T>) {
    self.dataSource = dataSource
  }

}

private class ChartSegment {
  
  var startAngle: CGFloat
  var endAngle: CGFloat
  var color: UIColor
  
  init(startAngle: CGFloat, endAngle: CGFloat, color: UIColor) {
    self.startAngle = startAngle
    self.endAngle = endAngle
    self.color = color
  }
  
}

public class Chart: UIView {
  
  private var segments: [ChartSegment] = []
  public var maxAngle: CGFloat = CGFloat(M_PI) * 2
  public var innerRadius: CGFloat = 0
  public var outerRadius: CGFloat = 0
  
}

private class ChartLayer: CALayer {
  
  struct PropertyKeys {
    static let startAngleKey = "startAngle"
    static let endAngleKey = "endAngle"
    static let innerRadiusKey = "innerRadius"
    static let outerRadiusKey = "outerRadius"
    
    static let colorKey = "color"
    
    static let animatableProperties = [startAngleKey, endAngleKey, innerRadiusKey, outerRadiusKey]
  }
  
  @NSManaged var startAngle: CGFloat
  @NSManaged var endAngle: CGFloat
  @NSManaged public var innerRadius: CGFloat
  @NSManaged public var outerRadius: CGFloat
  
  override func actionForKey(event: String) -> CAAction? {
    
    outer: if PropertyKeys.animatableProperties.contains(event) {
      if superlayer == nil {
        if PropertyKeys.outerRadiusKey == event
          || PropertyKeys.innerRadiusKey == event {
          break outer
        }
      }
      return animationForAngle(event)
    }
    return super.actionForKey(event)
  }
  
  func animationForAngle(key: String) -> CAAction {
    
    let animation = CABasicAnimation(keyPath: key)
    animation.duration = 0.75
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    if let value = presentationLayer()?.valueForKey(key) {
      animation.fromValue = value
    } else {
      animation.fromValue = 0.0
    }
    
    return animation
  }
  
  override class func needsDisplayForKey(key: String) -> Bool {
    if PropertyKeys.animatableProperties.contains(key) {
      return true
    }
    return super.needsDisplayForKey(key)
  }
}
