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

/* 
 * Provides keys for easy access to Chart properties
 */
private enum ChartProperties {
  static let dataSourceKey = "dataSource"
  static let maxAngleKey = "maxAngle"
  static let innerRadiusKey = "innerRadius"
  static let outerRadiusKey = "outerRadius"
}

/*
 * Chart is a `UIView` subclass that provides a graphical representation
 * of it's data source in the form of a pie chart. It manages an array of
 * SegmentLayers that draw each segment of the chart individually, and relies
 * on it's data source for relaying values (also angle values) for each layer.
 */
@objc
public class Chart: UIView {
  
  //MARK: - Public variables
  
  public var dataSource: DataSource?
  
  //MARK: - Public Inspectables
  
  @IBInspectable public var innerRadius: CGFloat = 0
  @IBInspectable public var outerRadius: CGFloat = 0
  @IBInspectable public var beginColor: UIColor? {
    didSet { reloadData() }
  }
  @IBInspectable public var endColor: UIColor? {
    didSet { reloadData() }
  }
  
  //MARK: - Private variables
  
  private var chartSegmentLayers: [SegmentLayer] = []
  private let chartContainer = UIView()
  private var outerRadiusRatio: CGFloat = 0.0
  private var innerRadiusRatio: CGFloat = 0.0
  
  //MARK: - Initializers
  
  /**
   Default initializer for ChartView, provides most of the customization points
  
   Note: `innerRadius` and `outerRadius` are initially used to calculate a ratio
   of these values to overal chart frame, so that the chart is sized correclty
   when changes to the frame are made
   
   Note: `beginColor` and `endColor` are used to derive a range, or gradient of 
   colors, that provide a smooth transition between each segment
   
   - parameter frame:       frame used to display the chart view; since chart 
   itself requires square bounds, the greates square frame that fits in the 
   frame is derived and centered in chart frame
   - parameter innerRadius: if larger than 0, defines the radius of an inner 
   'hole' in the chart
   - parameter outerRadius: defines the outer radius of the chart, should be 
   greater than `innerRadius`
   - parameter dataSource:  `DataSource` complying object that provides all
   data details for the chart view
   - parameter beginColor:  color of the first chart segment layer
   - parameter endColor:    color of the last chart segment layer
   
   - returns: fully configured chart view
   */
  public required init(frame: CGRect, innerRadius: CGFloat, outerRadius: CGFloat, dataSource: DataSource, beginColor: UIColor = UIColor.greenColor(), endColor: UIColor = UIColor.yellowColor()) {
    self.innerRadius = innerRadius
    self.outerRadius = outerRadius
    self.dataSource = dataSource
    self.beginColor = beginColor
    self.endColor = endColor
    
    super.init(frame: frame)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  //MARK: - Public Overrides
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    reloadData()
  }
  
  //MARK: - Setup
  
  /**
   Calculates the view that will hold individual `SegmentLayers` as well as
   the square frame for that view, in such a way that it fills the most of the
   available frame. 
   
   This is also used to resize the container appropriately with bounds changes, 
   as well as for the intial configuration of `outerRadiusRatio` and 
   `innerRadiusRatio`.
   */
  private func setupChartContainerIfNeeded() {
    
    let squareSide = min(frame.size.width, frame.size.height)
    let squaredBounds = CGRect(origin: CGPointZero, size: CGSize(width: squareSide, height: squareSide))
    
    chartContainer.bounds = squaredBounds
    chartContainer.center = bounds.center()
    chartContainer.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.6, alpha: 1.0)
    
    if chartContainer.superview == nil {
      addSubview(chartContainer)
    }
    
    if outerRadiusRatio == 0 {
      outerRadiusRatio = outerRadius / (chartContainer.frame.size.width / 2)
    }
    
    if innerRadiusRatio == 0 {
      innerRadiusRatio = innerRadius / (chartContainer.frame.size.width / 2)
    }
    
    for layer in chartSegmentLayers {
      layer.frame = chartContainer.bounds
      layer.position = chartContainer.bounds.center()
    }
  }
  
  /**
   A flag used to distinguish the entry animation (adding elements, clockwise) 
   from animation used for individual elements (adding elements, 
   counterclockwise).
   */
  private var initialAnimationComplete = false
  
  /**
   Querries the `dataSource` for data and inserts, removes, or updates all 
   relevant segments.
   */
  final public func reloadData() {
    guard let source = dataSource else {
      return
    }
    
    setupChartContainerIfNeeded()
    
    let pallette = UIColor.colorRange(beginColor: beginColor!, endColor: endColor!, count: source.numberOfItems())
    
    let refNumber = max(source.numberOfItems(), chartSegmentLayers.count)
    
    for index in 0..<refNumber {
      guard let item = source.item(index) else {
        remove(index)
        continue
      }
      
      guard let layer = layer(index) else {
        let layer = SegmentLayer(
          frame: chartContainer.bounds,
          start: source.startAngle(index),
          end: source.endAngle(index),
          outerRadius: outerRadius,
          innerRadius: innerRadius,
          color: pallette[index].CGColor
        )
        chartContainer.layer.addSublayer(layer)
        chartSegmentLayers.append(layer)
        layer.animateInsertion(initialAnimationComplete ? CGFloat(M_PI * 2) : 0)
        continue
      }
      
      layer.startAngle = source.startAngle(index)
      layer.endAngle = source.endAngle(index)
      layer.color = pallette[index].CGColor
      
      initialAnimationComplete = true
    }
  }

  /**
   Returns a `SegmentLayer?` for a given index
   
   - parameter index: Int, index to look at
   
   - returns: an optional value that's `nil` when index is out of bounds, and 
   SegmentLayer when a value is found
   */
  private func layer(index: Int) -> SegmentLayer? {
    if index >= chartSegmentLayers.count || index < 0 {
      return nil
    } else {
      return chartSegmentLayers[index]
    }
  }
  
  /**
   Removes the layer at a given index
   
   - parameter index:    index to remove
   - parameter animated: defaults to `true`, specifies whether the removal 
   should be animated
   */
  private func remove(index: Int, animated: Bool = true) {
    
    guard let layer = layer(index) else {
      return
    }
    
    if animated {
      layer.animateRemoval({
        self.chartSegmentLayers.removeAtIndex(index)
      })
    } else {
      self.chartSegmentLayers.removeAtIndex(index)
      layer.removeFromSuperlayer()
    }
  }
}
