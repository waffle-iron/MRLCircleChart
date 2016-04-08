//
//  Extensions.swift
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

extension CGRect {
  func center() -> CGPoint {
    return CGPoint(x: size.width / 2, y: size.height / 2)
  }
}

extension UIColor {
  
  class func colorRange(beginColor beginColor: UIColor, endColor: UIColor, count: Int) -> [UIColor] {
    
    var br: CGFloat = 0
    var bg: CGFloat = 0
    var bb: CGFloat = 0
    var ba: CGFloat = 0
    
    beginColor.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
    
    var er: CGFloat = 0
    var eg: CGFloat = 0
    var eb: CGFloat = 0
    var ea: CGFloat = 0
    
    endColor.getRed(&er, green: &eg, blue: &eb, alpha: &ea)
    
    var result:[UIColor] = []
    
    for index in 0..<count {
      var red = br - (br - er) / CGFloat(count) * CGFloat(index)
      var green = bg - (bg - eg) / CGFloat(count) * CGFloat(index)
      var blue = bb - (bb - eb) / CGFloat(count) * CGFloat(index)
      var alpha = ba - (ba - ea) / CGFloat(count) * CGFloat(index)
      
      let color = UIColor(red:red, green:green, blue:blue, alpha:alpha)
      
      result.append(color)
    }
    
    return result
  }
}