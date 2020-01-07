//
//  YAxisRenderer.swift
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

@objc(ChartYAxisRenderer)
open class YAxisRenderer: AxisRendererBase
{
    ///newAdd
    @objc open var isZMCus = false//分时图主图
    @objc open var isZMCus_increaseColor:UIColor? = UIColor.white //增
    @objc open var isZMCus_decreaseColor:UIColor? = UIColor.white //减
    @objc open var isZMCus_normalColor:UIColor? = UIColor.white //平
    
    @objc public init(viewPortHandler: ViewPortHandler, yAxis: YAxis?, transformer: Transformer?)
    {
        super.init(viewPortHandler: viewPortHandler, transformer: transformer, axis: yAxis)
    }
    
    /// draws the y-axis labels to the screen
    open override func renderAxisLabels(context: CGContext)
    {
        guard let yAxis = self.axis as? YAxis else { return }
        
        if !yAxis.isEnabled || !yAxis.isDrawLabelsEnabled
        {
            return
        }
        
        let xoffset = yAxis.xOffset
        let yoffset = yAxis.labelFont.lineHeight / 2.5 + yAxis.yOffset
        
        let dependency = yAxis.axisDependency
        let labelPosition = yAxis.labelPosition
        
        var xPos = CGFloat(0.0)
        
        var textAlign: NSTextAlignment
        
        if dependency == .left
        {
            if labelPosition == .outsideChart
            {
                textAlign = .right
                xPos = viewPortHandler.offsetLeft - xoffset
            }
            else
            {
                textAlign = .left
                xPos = viewPortHandler.offsetLeft + xoffset
            }
            
        }
        else
        {
            if labelPosition == .outsideChart
            {
                textAlign = .left
                xPos = viewPortHandler.contentRight + xoffset
            }
            else
            {
                textAlign = .right
                xPos = viewPortHandler.contentRight - xoffset
            }
        }
        
        let poss = transformedPositions()
        
        drawYLabels(
            context: context,
            fixedPosition: xPos,
            positions: transformedPositions(),
            offset: yoffset - yAxis.labelFont.lineHeight,
            textAlign: textAlign)
    }
    
    open override func renderAxisLine(context: CGContext)
    {
        guard let yAxis = self.axis as? YAxis else { return }
        
        if !yAxis.isEnabled || !yAxis.drawAxisLineEnabled
        {
            return
        }
        
        context.saveGState()
        
        context.setStrokeColor(yAxis.axisLineColor.cgColor)
        context.setLineWidth(yAxis.axisLineWidth)
        if yAxis.axisLineDashLengths != nil
        {
            context.setLineDash(phase: yAxis.axisLineDashPhase, lengths: yAxis.axisLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        if yAxis.axisDependency == .left
        {
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            context.strokePath()
        }
        else
        {
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentBottom))
            context.strokePath()
        }
        
        context.restoreGState()
    }
    
    /// draws the y-labels on the specified x-position
    internal func drawYLabels(
        context: CGContext,
        fixedPosition: CGFloat,
        positions: [CGPoint],
        offset: CGFloat,
        textAlign: NSTextAlignment)
    {
        guard
            let yAxis = self.axis as? YAxis
            else { return }
        
        let labelFont = yAxis.labelFont
        var labelTextColor = yAxis.labelTextColor
        
        let from = yAxis.isDrawBottomYLabelEntryEnabled ? 0 : 1
        //newAdd
//        let to = yAxis.isDrawTopYLabelEntryEnabled ? yAxis.entryCount : (yAxis.entryCount - 1)
        let to = yAxis.isDrawTopYLabelEntryEnabled ? positions.count : (positions.count - 1)

        for i in stride(from: from, to: to, by: 1)
        {
            let text = yAxis.getFormattedLabel(i)
            
            //newAdd
            if isZMCus == true {
                if i == 3 {
                    labelTextColor = isZMCus_normalColor!
                }else {
                    if i < 3{
                        labelTextColor = isZMCus_decreaseColor!
                    }
                    else {
                        labelTextColor = isZMCus_increaseColor!
                    }
                }
                
            }

            ChartUtils.drawText(
                context: context,
                text: text,
                point: CGPoint(x: fixedPosition, y: positions[i].y + offset),
                align: textAlign,
                attributes: [NSAttributedStringKey.font: labelFont, NSAttributedStringKey.foregroundColor: labelTextColor])
            
        }
    }
    
    open override func renderGridLines(context: CGContext)
    {
        guard let
            yAxis = self.axis as? YAxis
            else { return }
        
        if !yAxis.isEnabled
        {
            return
        }
        
        if yAxis.drawGridLinesEnabled
        {
            let positions = transformedPositions()
            
            context.saveGState()
            defer { context.restoreGState() }

 
//           context.clip(to: self.gridClippingRect)/*newAdd*/
            
            context.setShouldAntialias(yAxis.gridAntialiasEnabled)
            context.setStrokeColor(yAxis.gridColor.cgColor)
            context.setLineWidth(yAxis.gridLineWidth)
            context.setLineCap(yAxis.gridLineCap)
            
            if yAxis.gridLineDashLengths != nil
            {
                context.setLineDash(phase: yAxis.gridLineDashPhase, lengths: yAxis.gridLineDashLengths)
                
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            // draw the grid
            for i in 0 ..< positions.count
            {
                if isZMCus {
                    let mid = (positions.count - 1) / 2
                    if i == 0 || i == positions.count - 1 {
                        continue
                    }else if  i == mid {//|| i==0 || i==6
                        context.setLineDash(phase: 0.0, lengths: [])
                    }else {
                        context.setLineDash(phase: yAxis.gridLineDashPhase, lengths: yAxis.gridLineDashLengths)
                    }
                }

                ///[ newAdd - 等于绘制边框最高或者最低-不绘制
                let position = positions[i]
                if (position.y != viewPortHandler.contentBottom && position.y != viewPortHandler.contentTop /*&& _x > 0.1 && _x2 > 0.1*/)   {
                    drawGridLine(context: context, position: positions[i])
                }///]
                
            }
        }

        if yAxis.drawZeroLineEnabled
        {
            // draw zero line
            drawZeroLine(context: context)
        }
    }
    
    @objc open var gridClippingRect: CGRect
    {
        var contentRect = viewPortHandler.contentRect
        let dy = self.axis?.gridLineWidth ?? 0.0
        contentRect.origin.y -= dy / 2.0
        contentRect.size.height += dy
        return contentRect
    }
    
    @objc open func drawGridLine(
        context: CGContext,
        position: CGPoint)
    {
        context.beginPath()
        context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: position.y))
        context.addLine(to: CGPoint(x:/*newAdd*/UIScreen.main.bounds.size.width   /*viewPortHandler.contentRight*/, y: position.y))
//        context.setStrokeColor(UIColor.yellow.cgColor)

        context.strokePath()
    }
    
    @objc open func transformedPositions() -> [CGPoint]
    {
        guard
            let yAxis = self.axis as? YAxis,
            let transformer = self.transformer
            else { return [CGPoint]() }
        var positions = [CGPoint]()
        let entries = yAxis.entries
        
        if isZMCus {
            positions.reserveCapacity(yAxis.entryCount)
            for i in stride(from: 0, to: yAxis.entryCount, by: 1)
            {
                var p = CGPoint(x: 0.0, y: entries[i])
                positions.append(p)
            }
            transformer.pointValuesToPixel(&positions)
        }else {
            //newAdd
            for i in stride(from: 0, to: yAxis.entryCount, by: 1)
            {
                var p = CGPoint(x: 0.0, y: entries[i])
                //            positions.append(p)
                transformer.pointValueToPixel(&p)
                let lineH = yAxis.labelFont.lineHeight
//                if p.y - lineH >= viewPortHandler.contentTop && p.y <= viewPortHandler.contentBottom{
                    positions.append(p)
//                }
            }
        }
        return positions
    }

    /// Draws the zero line at the specified position.
    @objc open func drawZeroLine(context: CGContext)
    {
        guard
            let yAxis = self.axis as? YAxis,
            let transformer = self.transformer,
            let zeroLineColor = yAxis.zeroLineColor
            else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        var clippingRect = viewPortHandler.contentRect
        clippingRect.origin.y -= yAxis.zeroLineWidth / 2.0
        clippingRect.size.height += yAxis.zeroLineWidth
//        context.clip(to: clippingRect)/*newAdd*/

        context.setStrokeColor(zeroLineColor.cgColor)
        context.setLineWidth(yAxis.zeroLineWidth)
        
        let pos = transformer.pixelForValues(x: 0.0, y: 0.0)
    
        if yAxis.zeroLineDashLengths != nil
        {
            context.setLineDash(phase: yAxis.zeroLineDashPhase, lengths: yAxis.zeroLineDashLengths!)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: pos.y))
        context.addLine(to: CGPoint(x:/*newAdd viewPortHandler.contentRight*/ UIScreen.main.bounds.size.width , y: pos.y))
        context.drawPath(using: CGPathDrawingMode.stroke)
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        guard
            let yAxis = self.axis as? YAxis,
            let transformer = self.transformer
            else { return }
        
        var limitLines = yAxis.limitLines
        
        if limitLines.count == 0
        {
            return
        }
        
        context.saveGState()
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in 0 ..< limitLines.count
        {
            let l = limitLines[i]
            
            if !l.isEnabled
            {
                continue
            }
            
            context.saveGState()
            defer { context.restoreGState() }
            
            var clippingRect = viewPortHandler.contentRect
            clippingRect.origin.y -= l.lineWidth / 2.0
            clippingRect.size.height += l.lineWidth
            /*newAdd*/clippingRect.size.width = UIScreen.main.bounds.size.width
            context.clip(to: clippingRect)
            
            position.x = 0.0
            position.y = CGFloat(l.limit)
            position = position.applying(trans)
            
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: position.y))

            context.addLine(to: CGPoint(x:/*newAdd*/ UIScreen.main.bounds.size.width, y: position.y))
            
            context.setStrokeColor(l.lineColor.cgColor)
            context.setLineWidth(l.lineWidth)
            if l.lineDashLengths != nil
            {
                context.setLineDash(phase: l.lineDashPhase, lengths: l.lineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            context.strokePath()
            
            
            let label = l.label
            
            // if drawing the limit-value label is enabled
            if l.drawLabelEnabled && label.count > 0
            {
                let labelLineHeight = l.valueFont.lineHeight
                
               
                
                let xOffset: CGFloat = 4.0 + l.xOffset
                let yOffset: CGFloat = l.lineWidth + labelLineHeight + l.yOffset
                
                    if l.labelPosition == .rightTop
                    {
                        ChartUtils.drawText(context: context,
                                            text: label,
                                            point: CGPoint(
                                                x: viewPortHandler.contentRight - xOffset,
                                                y: position.y - yOffset),
                                            align: .right,
                                            attributes: [NSAttributedStringKey.font: l.valueFont, NSAttributedStringKey.foregroundColor: l.valueTextColor])
                    }
                    else if l.labelPosition == .rightBottom
                    {
                        ChartUtils.drawText(context: context,
                                            text: label,
                                            point: CGPoint(
                                                x: viewPortHandler.contentRight - xOffset,
                                                y: position.y + yOffset - labelLineHeight),
                                            align: .right,
                                            attributes: [NSAttributedStringKey.font: l.valueFont, NSAttributedStringKey.foregroundColor: l.valueTextColor])
                    }
                    else if l.labelPosition == .leftTop
                    {
                        //[newAdd
                        var space :CGFloat = 0.0
                        
                        if position.y >= viewPortHandler.contentTop && position.y <= viewPortHandler.contentBottom {
                            if position.y - labelLineHeight < viewPortHandler.contentTop {
                                space = viewPortHandler.contentTop
                            }else {
                                space = position.y - labelLineHeight
                            }
                            ChartUtils.drawText(context: context,
                                                text: label,
                                                point: CGPoint(
                                                    x: viewPortHandler.contentLeft + xOffset,
                                                    y: space),
                                                align: .left,
                                                attributes: [NSAttributedStringKey.font: l.valueFont, NSAttributedStringKey.foregroundColor: l.valueTextColor])
                        }
                        //]
                    }
                    else
                    {
                        ChartUtils.drawText(context: context,
                                            text: label,
                                            point: CGPoint(
                                                x: viewPortHandler.contentLeft + xOffset,
                                                y: position.y + yOffset - labelLineHeight),
                                            align: .left,
                                            attributes: [NSAttributedStringKey.font: l.valueFont, NSAttributedStringKey.foregroundColor: l.valueTextColor])
                    }
                
            }
        }
        
        context.restoreGState()
    }
}
