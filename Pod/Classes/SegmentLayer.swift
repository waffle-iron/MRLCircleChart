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
  
  struct Constants {
    static let animationDuration = 0.75
  }
  
  @NSManaged var startAngle: CGFloat
  @NSManaged var endAngle: CGFloat
  @NSManaged var innerRadius: CGFloat
  @NSManaged var outerRadius: CGFloat
  @NSManaged var color: CGColorRef
  
  init(frame:CGRect, start:CGFloat, end:CGFloat, outerRadius:CGFloat, innerRadius:CGFloat, color:CGColorRef) {
    super.init()
    
    self.frame = frame
    self.startAngle = start
    self.endAngle = end
    self.outerRadius = outerRadius
    self.innerRadius = innerRadius
    self.color = color

    self.commonInit()
  }
  
  override init(layer: AnyObject) {
    
    super.init(layer: layer)
    
    if layer.isKindOfClass(SegmentLayer) {
      self.startAngle = layer.startAngle
      self.endAngle = layer.endAngle
      self.outerRadius = layer.outerRadius
      self.innerRadius = layer.innerRadius
      self.color = layer.color
    }
    self.commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
  
    super.init(coder: aDecoder)
    
    self.color = aDecoder.decodeCGColorRefForKey(PropertyKeys.colorKey)
    self.startAngle = CGFloat(aDecoder.decodeFloatForKey(PropertyKeys.startAngleKey))
    self.endAngle = CGFloat(aDecoder.decodeFloatForKey(PropertyKeys.endAngleKey))
    self.outerRadius = CGFloat(aDecoder.decodeFloatForKey(PropertyKeys.outerRadiusKey))
    self.innerRadius = CGFloat(aDecoder.decodeFloatForKey(PropertyKeys.innerRadiusKey))
    
    self.commonInit()
  }
  
  func commonInit() {
    contentsScale = UIScreen.mainScreen().scale
  }
  
  override func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeFloat(Float(startAngle), forKey: PropertyKeys.startAngleKey)
    aCoder.encodeFloat(Float(endAngle), forKey: PropertyKeys.endAngleKey)
    aCoder.encodeFloat(Float(outerRadius), forKey: PropertyKeys.outerRadiusKey)
    aCoder.encodeFloat(Float(innerRadius), forKey: PropertyKeys.innerRadiusKey)
    aCoder.encodeCGColorRef(self.color, key: PropertyKeys.colorKey)
    
  }
  
  //MARK: - Animation Overrides
  
  override func actionForKey(event: String) -> CAAction? {
    
    let shouldSkipAnimationOnEntry = superlayer == nil && (PropertyKeys.outerRadiusKey == event
    || PropertyKeys.innerRadiusKey == event)
    
    if event == PropertyKeys.colorKey {
      return animationForColor()
    }
    
    outer: if PropertyKeys.animatableProperties.contains(event) {
      if shouldSkipAnimationOnEntry {
          break outer
      }
      return animationForAngle(event)
    }
    
    return nil//super.actionForKey(event)
  }
  
  func animation(key: String, toValue: AnyObject, fromValue: AnyObject) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: key)
    animation.duration = Constants.animationDuration
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    animation.toValue = toValue
    animation.fromValue = fromValue
    
    return animation
  }
  
  func animationForAngle(key: String) -> CAAction {
    
    let animation = CABasicAnimation(keyPath: key)
    animation.duration = Constants.animationDuration
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    if let value = presentationLayer()?.valueForKey(key) {
      animation.fromValue = value
    } else {
      animation.fromValue = 0.0
    }
    
    return animation
  }
  
  func animationForColor() -> CAAction {
    let animation = CABasicAnimation(keyPath: PropertyKeys.colorKey)
    animation.duration = Constants.animationDuration
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    if let value = presentationLayer()?.valueForKey(PropertyKeys.colorKey) {
      animation.fromValue = value
    } else {
      animation.fromValue = self.color
    }
    
    return animation
  }
  
  func animateRemoval(completion: () -> ()) {
    CATransaction.begin()
    CATransaction.setCompletionBlock({
      self.removeFromSuperlayer()
      completion()
    })
    
    self.addAnimation(animation(PropertyKeys.startAngleKey, toValue: M_PI * 2, fromValue: startAngle), forKey: "startAngle")
    self.addAnimation(animation(PropertyKeys.endAngleKey, toValue: M_PI * 2, fromValue: endAngle), forKey: "endAngle")
    self.addAnimation(animation("opacity", toValue: 0.0, fromValue: 1.0), forKey: "opacity")
    
    CATransaction.commit()
  }
  
  func animateInsertion() {
    CATransaction.begin()
    
    
    self.addAnimation(animation(PropertyKeys.startAngleKey, toValue: self.startAngle, fromValue: M_PI * 2), forKey: "startAngle")
    self.addAnimation(animation(PropertyKeys.endAngleKey, toValue: self.endAngle, fromValue: M_PI * 2), forKey: "endAngle")
    
    CATransaction.commit()
  }
  
  override class func needsDisplayForKey(key: String) -> Bool {
    if PropertyKeys.animatableProperties.contains(key) {
      return true
    }
    if key == PropertyKeys.colorKey {
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
    
    let innerStartPoint = CGPoint(
      x: center.x + innerRadius * cos(startAngle),
      y: center.y + innerRadius * sin(startAngle)
    )
    
    let outerStartPoint = CGPoint(
      x: center.x + outerRadius * cos(startAngle),
      y: center.y + outerRadius * sin(startAngle)
    )
    
    let innerEndPoint = CGPoint(
      x: center.x + innerRadius * cos(endAngle),
      y: center.y + innerRadius * sin(endAngle)
    )
    
    let outerEndPoint = CGPoint(
      x: center.x + outerRadius * cos(endAngle),
      y: center.y + outerRadius * sin(endAngle)
    )
    
    
    let path = UIBezierPath()
    
    path.moveToPoint(innerStartPoint)
    path.addLineToPoint(outerStartPoint)
    
    path.addArcWithCenter(
      center,
      radius: outerRadius,
      startAngle: self.startAngle,
      endAngle: self.endAngle,
      clockwise: true
    )
    
    path.addLineToPoint(innerEndPoint)
    
    path.addArcWithCenter(
      center,
      radius: innerRadius,
      startAngle: endAngle,
      endAngle: startAngle,
      clockwise: false
    )
    
//    let beginRoundCapOrigin = CGPoint.midPoint(innerStartPoint, rhs: outerStartPoint)
//    let beginRoundCap = UIBezierPath(arcCenter: beginRoundCapOrigin, radius: abs(round((outerRadius - innerRadius) / 2)), startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
//    path.appendPath(beginRoundCap)
//    
//    let endRoundCapOrigin = CGPoint.midPoint(innerEndPoint, rhs: outerEndPoint)
//    let endRoundCap = UIBezierPath(arcCenter: endRoundCapOrigin, radius: abs(round((outerRadius - innerRadius) / 2)), startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
//    path.appendPath(endRoundCap)
    
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
