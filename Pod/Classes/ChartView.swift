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

//class ChartSegment {
//  
//  var startAngle: CGFloat
//  var endAngle: CGFloat
//  var color: UIColor
//  
//  init(startAngle: CGFloat, endAngle: CGFloat, color: UIColor) {
//    self.startAngle = startAngle
//    self.endAngle = endAngle
//    self.color = color
//  }
//}

private enum ChartProperties {
  static let dataSourceKey = "dataSource"
  static let maxAngleKey = "maxAngle"
  static let innerRadiusKey = "innerRadius"
  static let outerRadiusKey = "outerRadius"
}

public class Chart<Segment: ChartValue>: UIView {
  
  public var dataSource: DataSource<Segment>?
  public var innerRadius: CGFloat = 0
  public var outerRadius: CGFloat = 0
  
  private var chartSegmentLayers: [SegmentLayer] = []
  private let chartContainer = UIView()

  public required init(frame: CGRect, innerRadius: CGFloat, outerRadius: CGFloat, dataSource: DataSource<Segment>) {
    self.innerRadius = innerRadius
    self.outerRadius = outerRadius
    self.dataSource = dataSource
    
    super.init(frame: frame)
    
    self.setupLayers()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    
    self.innerRadius = CGFloat(aDecoder.decodeFloatForKey(ChartProperties.innerRadiusKey))
    self.outerRadius = CGFloat(aDecoder.decodeFloatForKey(ChartProperties.outerRadiusKey))
    
    super.init(coder: aDecoder)
    
    self.setupLayers()
  }
  
  public override func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeFloat(Float(self.innerRadius), forKey: ChartProperties.innerRadiusKey)
    aCoder.encodeFloat(Float(self.outerRadius), forKey: ChartProperties.outerRadiusKey)
  }
  
  private func setupChartContainerIfNeeded() {
    if chartContainer.superview != nil {
      return
    }
    
    let squareSide = min(frame.size.width, frame.size.height)
    let squaredBounds = CGRect(origin: CGPointZero, size: CGSize(width: squareSide, height: squareSide))
    
    chartContainer.bounds = squaredBounds
    chartContainer.center = bounds.center()
    addSubview(chartContainer)
  }
  
  private func setupLayers() {
    
    guard let source = dataSource else {
      return
    }
    
    setupChartContainerIfNeeded()
    
    let pallette = UIColor.colorRange(beginColor: UIColor.redColor(), endColor: UIColor.greenColor(), count: source.numberOfItems)
    
    for index in 0..<source.numberOfItems {
      let layer = SegmentLayer(frame: chartContainer.bounds, start: source.startAngle(index) , end: source.endAngle(index), outerRadius: outerRadius, innerRadius: innerRadius, color: pallette[index].CGColor)
      chartContainer.layer.addSublayer(layer)
      chartSegmentLayers.insert(layer, atIndex: index)
    }
  }
}