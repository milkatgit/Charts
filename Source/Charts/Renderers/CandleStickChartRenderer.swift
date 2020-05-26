//
//  CandleStickChartRenderer.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


open class CandleStickChartRenderer: LineScatterCandleRadarRenderer
{
    //newAdd
    var arrowMinMax = "<---"


    @objc open weak var dataProvider: CandleChartDataProvider?
    
    @objc public init(dataProvider: CandleChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    open override func drawData(context: CGContext)
    {
        guard let dataProvider = dataProvider, let candleData = dataProvider.candleData else { return }

        for set in candleData.dataSets as! [ICandleChartDataSet]
        {
            if set.isVisible
            {
                drawDataSet(context: context, dataSet: set)
            }
        }
    }
    
    private var _shadowPoints = [CGPoint](repeating: CGPoint(), count: 4)
    private var _rangePoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _openPoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _closePoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _bodyRect = CGRect()
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    @objc open func drawDataSet(context: CGContext, dataSet: ICandleChartDataSet)
    {
        guard let dataProvider = dataProvider else { return }

        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        let barSpace = dataSet.barSpace
        let showCandleBar = dataSet.showCandleBar
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        context.saveGState()
        
        context.setLineWidth(dataSet.shadowWidth)
        
        //newAdd
        // 可见区域的最小最大值
        var minValue: Double = Double.greatestFiniteMagnitude
        var maxValue: Double = -Double.greatestFiniteMagnitude
        
        // 可见区域的最小最大值对应的X坐标点
        var minPositionX: Double!
        var maxPositionX: Double!
        
        for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1)
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? CandleChartDataEntry else { continue }
            
            let xPos = e.x
            
            let open = e.open
            let close = e.close
            let high = e.high
            let low = e.low
            
            //newAdd
            if minValue > low {
                minValue = low
                minPositionX = xPos
            }
            
            if maxValue < high {
                maxValue = high
                maxPositionX = xPos
            }
            
            let candleData = dataProvider.candleData
            
            if candleData?.ZMisUseEntryColor == true {//dataSet.ZMisUseEntryColor
                // calculate the shadow
                
                _shadowPoints[0].x = CGFloat(xPos)
                _shadowPoints[1].x = CGFloat(xPos)
                _shadowPoints[2].x = CGFloat(xPos)
                _shadowPoints[3].x = CGFloat(xPos)
                
                if open > close
                {
                    _shadowPoints[0].y = CGFloat(high * phaseY)
                    _shadowPoints[1].y = CGFloat(open * phaseY)
                    _shadowPoints[2].y = CGFloat(low * phaseY)
                    _shadowPoints[3].y = CGFloat(close * phaseY)
                }
                else if open < close
                {
                    _shadowPoints[0].y = CGFloat(high * phaseY)
                    _shadowPoints[1].y = CGFloat(close * phaseY)
                    _shadowPoints[2].y = CGFloat(low * phaseY)
                    _shadowPoints[3].y = CGFloat(open * phaseY)
                }
                else
                {
                    _shadowPoints[0].y = CGFloat(high * phaseY)
                    _shadowPoints[1].y = CGFloat(open * phaseY)
                    _shadowPoints[2].y = CGFloat(low * phaseY)
                    _shadowPoints[3].y = _shadowPoints[1].y
                }
                
                trans.pointValuesToPixel(&_shadowPoints)
                
                // draw the shadows
                var entryColor = e.ZMColorAndIsFill.count > 0 ? e.ZMColorAndIsFill[0] as! UIColor : nil
                var entryIsFilled = e.ZMColorAndIsFill.count > 1 ? e.ZMColorAndIsFill[1] as! Bool : nil

                if entryColor != nil {
                    context.setStrokeColor((entryColor?.cgColor)!)
                    context.strokeLineSegments(between: _shadowPoints)
                    
                    // calculate the body
                    
                    _bodyRect.origin.x = CGFloat(xPos) - 0.5 + barSpace
                    _bodyRect.origin.y = CGFloat(close * phaseY)
                    _bodyRect.size.width = (CGFloat(xPos) + 0.5 - barSpace) - _bodyRect.origin.x
                    _bodyRect.size.height = CGFloat(open * phaseY) - _bodyRect.origin.y
                    
                    trans.rectValueToPixel(&_bodyRect)
                    
                    // draw body differently for increasing and decreasing entry
                    if open == close {
                        
                        context.setStrokeColor((entryColor?.cgColor)!)
                        context.stroke(_bodyRect)
                    }else {
                        if entryIsFilled!
                        {
                            context.setFillColor((entryColor?.cgColor)!)
                            context.fill(_bodyRect)
                        }
                        else
                        {
                            context.setStrokeColor((entryColor?.cgColor)!)
                            context.stroke(_bodyRect)
                        }
                    }
                   
                }
                
               

            }else {
                if showCandleBar
                {
                    // calculate the shadow
                    
                    _shadowPoints[0].x = CGFloat(xPos)
                    _shadowPoints[1].x = CGFloat(xPos)
                    _shadowPoints[2].x = CGFloat(xPos)
                    _shadowPoints[3].x = CGFloat(xPos)
                    
                    if open > close
                    {
                        _shadowPoints[0].y = CGFloat(high * phaseY)
                        _shadowPoints[1].y = CGFloat(open * phaseY)
                        _shadowPoints[2].y = CGFloat(low * phaseY)
                        _shadowPoints[3].y = CGFloat(close * phaseY)
                    }
                    else if open < close
                    {
                        _shadowPoints[0].y = CGFloat(high * phaseY)
                        _shadowPoints[1].y = CGFloat(close * phaseY)
                        _shadowPoints[2].y = CGFloat(low * phaseY)
                        _shadowPoints[3].y = CGFloat(open * phaseY)
                    }
                    else
                    {
                        _shadowPoints[0].y = CGFloat(high * phaseY)
                        _shadowPoints[1].y = CGFloat(open * phaseY)
                        _shadowPoints[2].y = CGFloat(low * phaseY)
                        _shadowPoints[3].y = _shadowPoints[1].y
                    }
                    
                    trans.pointValuesToPixel(&_shadowPoints)
                    
                    // draw the shadows
                    
                    var shadowColor: NSUIColor! = nil
                    if dataSet.shadowColorSameAsCandle
                    {
                        if open > close
                        {
                            shadowColor = dataSet.decreasingColor ?? dataSet.color(atIndex: j)
                        }
                        else if open < close
                        {
                            shadowColor = dataSet.increasingColor ?? dataSet.color(atIndex: j)
                        }
                        else
                        {
                            shadowColor = dataSet.neutralColor ?? dataSet.color(atIndex: j)
                        }
                    }
                    
                    if shadowColor === nil
                    {
                        shadowColor = dataSet.shadowColor ?? dataSet.color(atIndex: j)
                    }
                    
                    context.setStrokeColor(shadowColor.cgColor)
                    context.strokeLineSegments(between: _shadowPoints)
                    
                    // calculate the body
                    
                    _bodyRect.origin.x = CGFloat(xPos) - 0.5 + barSpace
                    _bodyRect.origin.y = CGFloat(close * phaseY)
                    _bodyRect.size.width = (CGFloat(xPos) + 0.5 - barSpace) - _bodyRect.origin.x
                    _bodyRect.size.height = CGFloat(open * phaseY) - _bodyRect.origin.y
                    
                    trans.rectValueToPixel(&_bodyRect)
                    
                    // draw body differently for increasing and decreasing entry
                    
                    if open > close
                    {
                        let color = dataSet.decreasingColor ?? dataSet.color(atIndex: j)
                        
                        if dataSet.isDecreasingFilled
                        {
                            context.setFillColor(color.cgColor)
                            context.fill(_bodyRect)
                        }
                        else
                        {
                            context.setStrokeColor(color.cgColor)
                            context.stroke(_bodyRect)
                        }
                    }
                    else if open < close
                    {
                        let color = dataSet.increasingColor ?? dataSet.color(atIndex: j)
                        
                        if dataSet.isIncreasingFilled
                        {
                            context.setFillColor(color.cgColor)
                            context.fill(_bodyRect)
                        }
                        else
                        {
                            context.setStrokeColor(color.cgColor)
                            context.stroke(_bodyRect)
                        }
                    }
                    else
                    {
                        let color = dataSet.neutralColor ?? dataSet.color(atIndex: j)
                        
                        context.setStrokeColor(color.cgColor)
                        context.stroke(_bodyRect)
                    }
                }
                else
                {
                    _rangePoints[0].x = CGFloat(xPos)
                    _rangePoints[0].y = CGFloat(high * phaseY)
                    _rangePoints[1].x = CGFloat(xPos)
                    _rangePoints[1].y = CGFloat(low * phaseY)
                    
                    _openPoints[0].x = CGFloat(xPos) - 0.5 + barSpace
                    _openPoints[0].y = CGFloat(open * phaseY)
                    _openPoints[1].x = CGFloat(xPos)
                    _openPoints[1].y = CGFloat(open * phaseY)
                    
                    _closePoints[0].x = CGFloat(xPos) + 0.5 - barSpace
                    _closePoints[0].y = CGFloat(close * phaseY)
                    _closePoints[1].x = CGFloat(xPos)
                    _closePoints[1].y = CGFloat(close * phaseY)
                    
                    trans.pointValuesToPixel(&_rangePoints)
                    trans.pointValuesToPixel(&_openPoints)
                    trans.pointValuesToPixel(&_closePoints)
                    
                    // draw the ranges
                    var barColor: NSUIColor! = nil
                    
                    if open > close
                    {
                        barColor = dataSet.decreasingColor ?? dataSet.color(atIndex: j)
                    }
                    else if open < close
                    {
                        barColor = dataSet.increasingColor ?? dataSet.color(atIndex: j)
                    }
                    else
                    {
                        barColor = dataSet.neutralColor ?? dataSet.color(atIndex: j)
                    }
                    
                    context.setStrokeColor(barColor.cgColor)
                    context.strokeLineSegments(between: _rangePoints)
                    context.strokeLineSegments(between: _openPoints)
                    context.strokeLineSegments(between: _closePoints)
                }
            }
            
            //newAdd
            if !e.ZMContractName.isEmpty {
                let path = CGMutablePath()
                var p1 = CGPoint(x: CGFloat(xPos - 0.5), y: 0)
                var p2 = CGPoint(x: CGFloat(xPos - 0.5), y: 0)
                trans.pointValueToPixel(&p1)
                trans.pointValueToPixel(&p2)

                p2.y = viewPortHandler.contentBottom
                p1.y = viewPortHandler.contentBottom - 30

                ChartUtils.drawText(context: context, text: e.ZMContractName, point: CGPoint(x: p1.x, y: p2.y - 13), align: .left, attributes: [NSAttributedStringKey.font: self.valueFontSize, NSAttributedStringKey.foregroundColor: UIColor.yellow])
                
                path.move(to: p1)
                path.addLine(to: p2)
                context.addPath(path)
                context.setFillColor(UIColor.yellow.cgColor)
                context.setLineWidth(1)
                context.setStrokeColor(UIColor.yellow.cgColor)
                context.strokePath()
            }
           
        }
        
        //newAdd
        let candleData = dataProvider.candleData

        if candleData?.ZM_isDrawMinMax == true {
           
            // 可见区域最左边的那条数据
            guard let lowestVisbleEntry = dataSet.entryForIndex(_xBounds.min) as? CandleChartDataEntry else {
                return
            }
            var lowestVisblePoint: CGPoint = CGPoint.init(x: lowestVisbleEntry.x, y: lowestVisbleEntry.high) // 此处主要是为了获取X坐标，lowestVisbleEntry.high可为low、open、close
            trans.pointValueToPixel(&lowestVisblePoint)
            
            // 可见区域最右边的那条数据
            guard let highestVisbleEntry = dataSet.entryForIndex( _xBounds.range + _xBounds.min) as? CandleChartDataEntry else {
                return
            }
            var highestVisblePoint: CGPoint = CGPoint.init(x: highestVisbleEntry.x, y: highestVisbleEntry.high)
            trans.pointValueToPixel(&highestVisblePoint)
            
            // 可见区域中的最小值
            let minValueStr = self.priceString(decimalNumber: NSDecimalNumber(value: minValue), marketDot: Int32(marketDot))
            
            var minPoint: CGPoint = CGPoint.init(x: CGFloat(minPositionX - 0.5), y: CGFloat(minValue * animator.phaseY))
            var minPoint2: CGPoint = CGPoint.init(x: CGFloat(minPositionX + 0.5), y: CGFloat(minValue * animator.phaseY))

            // 点转化为像素
            trans.pointValueToPixel(&minPoint)
            trans.pointValueToPixel(&minPoint2)

            calculateTextPosition(minValueStr, originPoint: &minPoint, originPoint2: &minPoint2, lowestVisibleX: lowestVisblePoint.x, highestVisibleX: highestVisblePoint.x, isMaxValue: false, context: context)
            
            // 可见区域中的最大值
            let maxValueStr = self.priceString(decimalNumber: NSDecimalNumber(value: maxValue), marketDot: Int32(marketDot))
            
            var maxPoint: CGPoint = CGPoint.init(x: CGFloat(maxPositionX - 0.5), y: CGFloat(maxValue * animator.phaseY))
            var maxPoint2: CGPoint = CGPoint.init(x: CGFloat(maxPositionX + 0.5), y: CGFloat(maxValue * animator.phaseY))

            trans.pointValueToPixel(&maxPoint)
            trans.pointValueToPixel(&maxPoint2)

            calculateTextPosition(maxValueStr, originPoint: &maxPoint, originPoint2: &maxPoint2, lowestVisibleX: lowestVisblePoint.x, highestVisibleX: highestVisblePoint.x, isMaxValue: true, context: context)
            
            
        }
       

        context.restoreGState()
    }
    
    func priceString(decimalNumber: NSDecimalNumber, marketDot: Int32) -> String {
        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: Int16(marketDot), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        
        let result = decimalNumber.rounding(accordingToBehavior: handler)
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = Int(marketDot)
        formatter.minimumFractionDigits = Int(marketDot)
        return formatter.string(from: result)!
    }
   
    //newAdd
    // 计算绘制位置并绘制文本 edited by Leo
    fileprivate func calculateTextPosition(_ valueText: String, originPoint: inout CGPoint,originPoint2: inout CGPoint, lowestVisibleX: CGFloat, highestVisibleX: CGFloat, isMaxValue: Bool,context:CGContext){
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font: self.valueFontSize ?? UIColor.red, NSAttributedStringKey.foregroundColor: isMaxValue==true ? self.increaceColor:self.decreaceColor]
        
        var stringText : String = "2"

        let h = valueText.boundingRect(with: CGSize.init(width: Int(200.0), height: 0), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        let textHight = h.height
        
        var usePoint = originPoint
        
        if isMaxValue {
            if originPoint.y-textHight >= viewPortHandler.contentTop {//放到kline上方
                stringText = "\(valueText)"
                originPoint2.y -= textHight
                usePoint = originPoint2
            }else {
                stringText = "\(valueText)" + arrowMinMax
                originPoint.y = viewPortHandler.contentTop - 2.0
                usePoint = originPoint
            }
            
        } else {
            if originPoint.y+textHight <= viewPortHandler.contentBottom {//放到kline下方
                stringText = "\(valueText)"
                originPoint2.y += 0
                usePoint = originPoint2
            }else {
                stringText = "\(valueText)" + arrowMinMax
                originPoint.y = viewPortHandler.contentBottom - textHight
                usePoint = originPoint
            }
        }
        ChartUtils.drawText(context: context, text: stringText, point: usePoint, align: .right, attributes: attributes)
    }
    open override func drawValues(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let candleData = dataProvider.candleData
            else { return }
        
        // if values are drawn
        if isDrawingValuesAllowed(dataProvider: dataProvider)
        {
            var dataSets = candleData.dataSets
            
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0 ..< dataSets.count
            {
                guard let dataSet = dataSets[i] as? IBarLineScatterCandleBubbleChartDataSet
                    else { continue }
                
                if !shouldDrawValues(forDataSet: dataSet)
                {
                    continue
                }
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let iconsOffset = dataSet.iconsOffset
                
                _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
                
                let lineHeight = valueFont.lineHeight
                let yOffset: CGFloat = lineHeight + 5.0
                
                for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1)
                {
                    guard let e = dataSet.entryForIndex(j) as? CandleChartDataEntry else { break }
                    
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.high * phaseY)
                    pt = pt.applying(valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                    {
                        continue
                    }
                    
                    if dataSet.isDrawValuesEnabled
                    {
                        ChartUtils.drawText(
                            context: context,
                            text: formatter.stringForValue(
                                e.high,
                                entry: e,
                                dataSetIndex: i,
                                viewPortHandler: viewPortHandler),
                            point: CGPoint(
                                x: pt.x,
                                y: pt.y - yOffset),
                            align: .center,
                            attributes: [NSAttributedStringKey.font: valueFont, NSAttributedStringKey.foregroundColor: dataSet.valueTextColorAt(j)])
                    }
                    
                    if let icon = e.icon, dataSet.isDrawIconsEnabled
                    {
                        ChartUtils.drawImage(context: context,
                                             image: icon,
                                             x: pt.x + iconsOffset.x,
                                             y: pt.y + iconsOffset.y,
                                             size: icon.size)
                    }
                }
            }
        }
    }
    
    open override func drawExtras(context: CGContext)
    {
        
    }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let candleData = dataProvider.candleData
            else { return }
        
        context.saveGState()
        
        for high in indices
        {
            guard
                let set = candleData.getDataSetByIndex(high.dataSetIndex) as? ICandleChartDataSet,
                set.isHighlightEnabled
                else { continue }
            
            guard let e = set.entryForXValue(high.x, closestToY: high.y) as? CandleChartDataEntry else { continue }
            
            if !isInBoundsX(entry: e, dataSet: set)
            {
                continue
            }
            
            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
            
            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            
            if set.highlightLineDashLengths != nil
            {
                context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let lowValue = e.low * Double(animator.phaseY)
            let highValue = e.high * Double(animator.phaseY)
            let y = (lowValue + highValue) / 2.0
            
            let pt = trans.pixelForValues(x: e.x, y: y)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
        }
        
        context.restoreGState()
    }
}
