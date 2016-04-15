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

private enum ChartProperties {
  static let dataSourceKey = "dataSource"
  static let maxAngleKey = "maxAngle"
  static let innerRadiusKey = "innerRadius"
  static let outerRadiusKey = "outerRadius"
}

@objc
public class Chart: UIView {
  
  //MARK: - Public variables
  
  public var dataSource: DataSource?
  
  //MARK: - Public Inspectables
  
  @IBInspectable public var innerRadius: CGFloat = 0
  @IBInspectable public var outerRadius: CGFloat = 0
  @IBInspectable public var beginColor: UIColor? {
    didSet { updateLayers() }
  }
  @IBInspectable public var endColor: UIColor? {
    didSet { updateLayers() }
  }
  
  //MARK: - Private variables
  
  private var chartSegmentLayers: [SegmentLayer] = []
  private let chartContainer = UIView()
  private var outerRadiusRatio: CGFloat = 0.0
  private var innerRadiusRatio: CGFloat = 0.0
  
  //MARK: - Initializers
  
  public required init(frame: CGRect, innerRadius: CGFloat, outerRadius: CGFloat, dataSource: DataSource, beginColor: UIColor = UIColor.greenColor(), endColor: UIColor = UIColor.yellowColor()) {
    self.innerRadius = innerRadius
    self.outerRadius = outerRadius
    self.dataSource = dataSource
    self.beginColor = beginColor
    self.endColor = endColor
    
    super.init(frame: frame)
    commonInit()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  func commonInit() {
    
  }
  
  //MARK: - Public Overrides
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    updateLayers()
  }
  
  //MARK: - Setup
  
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
  
  public func reloadData() {
    self.updateLayers()
  }

  private func updateLayers() {
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
        let layer = SegmentLayer(frame: chartContainer.bounds, start: source.startAngle(index), end: source.endAngle(index), outerRadius: outerRadius, innerRadius: innerRadius, color: pallette[index].CGColor)
        chartContainer.layer.addSublayer(layer)
        chartSegmentLayers.append(layer)
        layer.animateInsertion()
        continue
      }
      
      layer.startAngle = source.startAngle(index)
      layer.endAngle = source.endAngle(index)
      layer.color = pallette[index].CGColor
      
    }
  }
  
  private func layer(index: Int) -> SegmentLayer? {
    if index >= chartSegmentLayers.count || index < 0 {
      return nil
    } else {
      return chartSegmentLayers[index]
    }
  }
  
  private func remove(index: Int, animated: Bool = true) {
    let layer = self.chartSegmentLayers[index]
    if animated {
      layer.animateRemoval({
        if self.chartSegmentLayers.count > index {
          self.chartSegmentLayers.removeAtIndex(index)
        }
      })
    }
  }
  
  private func insert(index: Int, animated: Bool = true) {
    let layer = self.chartSegmentLayers[index]
    layer.animateInsertion()
  }
}
