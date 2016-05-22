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
/**
 `CALayer` subclass used by the chart view to draw the individual segments of
 it's pie chart. This class is only used internally.
 */
class SegmentLayer: CALayer {
  /**
   Defines the keys for encodeable properties of the layer. Also, exposes 
   `animatableProperties`, an array of keys for properties that require custom
   animations.
   */
  struct PropertyKeys {
    static let startAngleKey = "startAngle"
    static let endAngleKey = "endAngle"
    static let innerRadiusKey = "innerRadius"
    static let outerRadiusKey = "outerRadius"
    static let colorKey = "color"
    static let capType = "capType"
    
    static let animatableProperties = [colorKey, startAngleKey, endAngleKey, innerRadiusKey, outerRadiusKey]
  }
  /**
   Constants used by `SegmentLayer`
   */
  struct Constants {
    static let animationDuration = 0.75
  }
  
  var selected = false
  
  @NSManaged var startAngle: CGFloat
  @NSManaged var endAngle: CGFloat
  @NSManaged var innerRadius: CGFloat
  @NSManaged var outerRadius: CGFloat
  @NSManaged var color: CGColorRef
  
  var animationDuration: Double = Constants.animationDuration
  
  @objc
  enum SegmentCapType: Int {
    case None, Begin, End, Middle, BothEnds
  }
  
  @NSManaged var capType: SegmentCapType
  
  /**
   Default initialized for `SegmentLayer`, provides all necessary customization
   points.
   
   - parameter frame:       frame in which to draw the segment. Note that this 
   frame should be identical for all chart segments.
   - parameter start:       angle at which to begin drawing
   - parameter end:         angle at which to stop drawing
   - parameter outerRadius: radius of the outer border
   - parameter innerRadius: radius of the inner border, used to 'punch a hole' 
   in the center of the chart, can be 0 for a full chart
   - parameter color:       `CGColorRef` color of the segment
   
   - returns: a fully configured `SegmentLayer` instance
   */

  required init(frame:CGRect, start:CGFloat, end:CGFloat, outerRadius:CGFloat, innerRadius:CGFloat, color:CGColorRef) {
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
      self.capType = layer.capType
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
  
  /**
   Common initialization point, to be used for any operation that are common
   to all initializers and can be performed after `self` is available.
   */
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
  //TODO: examine how superclass's properties (eg. frame) are animated and decide whether these should be enabled.
  /**
   Overrides `CALayer`'s `actionForKey(_:)` method to specify animation 
   behaviour for custom properties.
   Currently returns an animation action only for keys defined in 
   `PropertyKeys.animatableProperties` `Array`.
   
   - parameter event: String corresponding to the property key
  
   - returns: a custom animation for specified properties or `nil` for everything
   else
   */
  override func actionForKey(event: String) -> CAAction? {
    
    let shouldSkipAnimationOnEntry = superlayer == nil
      && (PropertyKeys.outerRadiusKey == event
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
  
  /**
   Helper function to generate similar `CAAnimations` easily
   */
  func animation(key: String, toValue: AnyObject, fromValue: AnyObject) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: key)
    animation.duration = animationDuration
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    animation.toValue = toValue
    animation.fromValue = fromValue
    
    return animation
  }
  
  /**
   Provides an animation tailored for the start- and endAngle properties.
   */
  func animationForAngle(key: String) -> CAAction {
    let animation = CABasicAnimation(keyPath: key)
    animation.duration = animationDuration
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    if let value = presentationLayer()?.valueForKey(key) {
      animation.fromValue = value
    } else {
      animation.fromValue = CGFloat(M_PI) * 2
    }
    
    return animation
  }
  
  /**
   Provides an animation tailored for the color property.
   */
  func animationForColor() -> CAAction {
    let animation = CABasicAnimation(keyPath: PropertyKeys.colorKey)
    animation.duration = animationDuration
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    if let value = presentationLayer()?.valueForKey(PropertyKeys.colorKey) {
      animation.fromValue = value
    } else {
      animation.fromValue = self.color
    }
    
    return animation
  }
  
  /**
   Animates the removal of the layer from it's `superlayer`. It will run 
   `removeFromSuperlayer` when the animation completes, and provides a 
   `completion` closure that is run after the `removeFromSuperlayer` call.
   */
  func animateRemoval(startAngle exitingStartAngle: CGFloat, endAngle exitingEndAngle: CGFloat, completion: () -> ()) {
    CATransaction.begin()
    CATransaction.setCompletionBlock({
      self.removeFromSuperlayer()
      completion()
    })

    self.startAngle = exitingStartAngle
    self.endAngle = exitingEndAngle
    
    CATransaction.commit()
  }
  
  /**
   Animates the insertion of the layer, given an initial `startAngle` and, 
   optionally, an initial `endAngle` (defaults to startAngle).
   */
  func animateInsertion(startAngle: CGFloat, endAngle: CGFloat? = nil) {
    let initialEndAngle = endAngle == nil ? startAngle : endAngle!
    
    CATransaction.begin()
    
    self.addAnimation(animation(PropertyKeys.startAngleKey, toValue: self.startAngle, fromValue: startAngle), forKey: PropertyKeys.startAngleKey)
    self.addAnimation(animation(PropertyKeys.endAngleKey, toValue: self.endAngle, fromValue: initialEndAngle), forKey: PropertyKeys.endAngleKey)
    
    CATransaction.commit()
  }
  
  override class func needsDisplayForKey(key: String) -> Bool {
    if PropertyKeys.animatableProperties.contains(key)
      || key == PropertyKeys.capType {
      return true
    }
    return super.needsDisplayForKey(key)
  }

  
  //MARK: - Drawing
  
  override func drawInContext(ctx: CGContext) {
    CGContextBeginPath(ctx)
    CGContextAddPath(ctx, path())
    CGContextSetFillColorWithColor(ctx, color)
    CGContextDrawPath(ctx, .Fill)
  }
  
  /**
   Provides a `CGPathRef` that is used for drawing the segment layer as well as for
   hit testing. Radii and angle properties together with layer's bounds are used
   to calculate the path.
   */
  func path() -> CGPathRef {
    
    let center = bounds.center()
    
    func point(center:CGPoint) -> (CGFloat, CGFloat) -> CGPoint {
      return {(radius: CGFloat, angle: CGFloat) -> CGPoint in
        return CGPoint(
          x: center.x + radius * cos(angle),
          y: center.y + radius * sin(angle)
        )
      }
    }
    
    let pointOnCircle = point(center)
    
    let innerStartPoint = pointOnCircle(innerRadius, startAngle)
    let outerStartPoint = pointOnCircle(outerRadius, startAngle)
    let innerEndPoint = pointOnCircle(innerRadius, endAngle)
    
    func addCapToPath(path: UIBezierPath, angle: CGFloat, start: Bool) {
      let capRadius = abs(outerRadius - innerRadius) / 2
      let capCenterDistance = outerRadius - capRadius
      let capStartAngle =  CGFloat(M_PI) + angle
      let capEndAngle = CGFloat(M_PI * 2) + angle
      path.addArcWithCenter(pointOnCircle(capCenterDistance, angle), radius: capRadius, startAngle: capStartAngle, endAngle: capEndAngle, clockwise: start)
    }
    
    let path = UIBezierPath()
    
    path.moveToPoint(innerStartPoint)
    
    switch capType {
    case .BothEnds, .Begin:
      addCapToPath(path, angle: startAngle, start: true)
    default:
      path.addLineToPoint(outerStartPoint)
    }
    
    path.addArcWithCenter(
      center,
      radius: outerRadius,
      startAngle: self.startAngle,
      endAngle: self.endAngle,
      clockwise: true
    )
  
    switch capType {
    case .BothEnds, .End:
      addCapToPath(path, angle: endAngle, start: false)
    default:
      path.addLineToPoint(innerEndPoint)
    }
    
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
