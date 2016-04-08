//
//  SegmentLayer.swift
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

class SegmentLayer: CALayer {
  
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
  @NSManaged var innerRadius: CGFloat
  @NSManaged var outerRadius: CGFloat
  
  var color: CGColorRef
  
  init(frame:CGRect, start:CGFloat, end:CGFloat, outerRadius:CGFloat, innerRadius:CGFloat, color:CGColorRef) {
    self.color = color
    
    super.init()
    
    self.frame = frame
    self.startAngle = start
    self.endAngle = end
    self.outerRadius = outerRadius
    self.innerRadius = innerRadius
    
    self.commonInit()
  }
  
  override init(layer: AnyObject) {
    self.color = layer.color
    
    super.init(layer: layer)
    
    if layer.isKindOfClass(SegmentLayer) {
      self.startAngle = layer.startAngle
      self.endAngle = layer.endAngle
      self.outerRadius = layer.outerRadius
      self.innerRadius = layer.innerRadius
    }
    self.commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    let colorArray = aDecoder.decodeObjectForKey(PropertyKeys.colorKey) as! [CGFloat]
    self.color = CGColorCreate(CGColorSpaceCreateDeviceRGB(), colorArray)!
    
    super.init(coder: aDecoder)
    
    self.startAngle = CGFloat(aDecoder.decodeFloatForKey(PropertyKeys.startAngleKey))
    self.endAngle = CGFloat(aDecoder.decodeFloatForKey(PropertyKeys.endAngleKey))
    self.outerRadius = CGFloat(aDecoder.decodeFloatForKey(PropertyKeys.outerRadiusKey))
    self.innerRadius = CGFloat(aDecoder.decodeFloatForKey(PropertyKeys.innerRadiusKey))
    
    self.commonInit()
  }
  
  func commonInit() {
    contentsScale = UIScreen.mainScreen().scale
  }
  
  //MARK: - Animation Overrides
  
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

  
  //MARK: - Drawing
  
  override func drawInContext(ctx: CGContext) {
    CGContextBeginPath(ctx)
    CGContextAddPath(ctx, path())
    CGContextSetStrokeColorWithColor(ctx, color)
    CGContextSetFillColorWithColor(ctx, color)
    CGContextDrawPath(ctx, .Fill)
  }
  
  func path() -> CGPathRef {
    
    let center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height/2)
    let path = UIBezierPath()
    
    path.moveToPoint(
      CGPoint(
        x: center.x + innerRadius * cos(startAngle),
        y: center.y + innerRadius * sin(startAngle)
      )
    )
    
    path.addLineToPoint(
      CGPoint(
        x: center.x + outerRadius * cos(startAngle),
        y: center.y + outerRadius * sin(startAngle)
      )
    )
    
    path.addArcWithCenter(
      center,
      radius: outerRadius,
      startAngle: self.startAngle,
      endAngle: self.endAngle,
      clockwise: true
    )
    
    path.addLineToPoint(
      CGPoint(
        x: center.x + innerRadius * cos(endAngle),
        y: center.y + innerRadius * sin(endAngle)
      )
    )
    
    path.addArcWithCenter(
      center,
      radius: innerRadius,
      startAngle: endAngle,
      endAngle: startAngle,
      clockwise: false
    )
    
    return path.CGPath
  }
  
  
  //MARK: - Hit Testing
  
  override func containsPoint(p: CGPoint) -> Bool {
    var transform = CGAffineTransformIdentity
    return withUnsafePointer(&transform, { (pointer: UnsafePointer<CGAffineTransform>) -> Bool in
      CGPathContainsPoint(path(), pointer, p, false)
    })
  }
}
