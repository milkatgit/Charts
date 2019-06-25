//
//  ChartDataEntry.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class ChartDataEntry: ChartDataEntryBase
{
    //newAdd
    /// 传入text 天眼2号根据text绘制对应的箭头
    @objc open var ZM_drawLabelText : String?
    /// 传入一个(颜色,是否填充)数组 用于bar
    @objc open var ZMColorAndIsFill : [Any] = []
    /// the x value
    @objc open var x = Double(0.0)
    /// 以这个点为起点画线
    @objc open var isStartLinePoint = false
    /// 以这个点为终点画线
    @objc open var isEndLinePoint = false
    /// 一日分时有多少分钟
    @objc open var cycleCount = 0
    /// 互惠这个点/不绘制
    @objc open var isContinue = false
    /// 为true 不绘制这个点
    @objc open var isNoDraw = false
    public required init()
    {
        super.init()
    }
    
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    @objc public init(x: Double, y: Double)
    {
        super.init(y: y)
        
        self.x = x
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter data: Space for additional data this Entry represents.
    
    @objc public init(x: Double, y: Double, data: AnyObject?)
    {
        super.init(y: y)
        
        self.x = x
    
        
        self.data = data
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    
    @objc public init(x: Double, y: Double, icon: NSUIImage?)
    {
        super.init(y: y, icon: icon)
        
        self.x = x
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    /// - parameter data: Space for additional data this Entry represents.
    
    @objc public init(x: Double, y: Double, icon: NSUIImage?, data: AnyObject?)
    {
        super.init(y: y, icon: icon, data: data)
        
        self.x = x
    }
        
    // MARK: NSObject
    
    open override var description: String
    {
        return "ChartDataEntry, x: \(x), y \(y)"
    }
    
    // MARK: NSCopying
    
    @objc open func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = type(of: self).init()
        
        copy.x = x
        copy.y = y
        copy.data = data
        
        return copy
    }
}

// MARK: Equatable
extension ChartDataEntry/*: Equatable*/ {
    open override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ChartDataEntry else { return false }

        if self === object
        {
            return true
        }

        return ((data == nil && object.data == nil) || (data?.isEqual(object.data) ?? false))
            && y == object.y
            && x == object.x
    }
}
