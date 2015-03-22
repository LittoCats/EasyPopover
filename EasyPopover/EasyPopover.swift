//
//  EasyPopover.swift
//  EasyPopover
//
//  Created by 程巍巍 on 3/21/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit

final class EasyPopover: UIView {
    private let arrowSize: CGFloat = 12.0
    private let cornerRadius: CGFloat = 8.0
    private let borderSize: CGFloat = 8.0

    private var scrollView: UIScrollView = UIScrollView()
    private weak var contentView: UIView?
    private var arrowPosition = (from: CGPointZero, pass: CGPointZero, to: CGPointZero)
    
    /**
    *   初始化 popover
    *   contentView 需设置期望显示的大小
    */
    init(contentView view: UIView, tintColor: UIColor = UIColor.clearColor()){
        super.init(frame: CGRectZero)
        self.backgroundColor = tintColor
        self.tintColor = view.backgroundColor
        self.clipsToBounds = true
        self.contentView = view
        self.scrollView.addSubview(view)
        self.scrollView.contentSize = view.bounds.size
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.clipsToBounds = true
        self.scrollView.layer.cornerRadius = cornerRadius
        self.scrollView.backgroundColor = view.backgroundColor
        self.addSubview(self.scrollView)
    }
    /**
    *   
    */
    func popFromRect(rect: CGRect, inView view: UIView, animated: Bool = true){
        self.frame = view.bounds
        positionFitToRect(rect, inView: view)
        if contentView!.isKindOfClass(UIScrollView.self) {
            contentView!.frame = scrollView.frame
        }
        view.addSubview(self)
        view.addObserver(self, forKeyPath: "frame", options: .Old, context: nil)
        if !animated {return}
        // 动画
        let center = self.center
        let frame = self.frame
        self.transform = CGAffineTransformMakeScale(0.01, 0.001)
        self.center = arrowPosition.pass
        UIView.animateWithDuration(0.175, animations: { () -> Void in
            self.center = center
            self.transform = CGAffineTransformMakeScale(1.0, 1.0)
        })
    }
    
    func dismiss(animated: Bool = true){
        self.superview?.removeObserver(self, forKeyPath: "frame", context: nil)
        if !animated { self.removeFromSuperview(); return}
        
        UIView.animateWithDuration(0.175, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(0.01, 0.01)
            self.center = self.arrowPosition.pass
        }) { (complete: Bool) -> Void in
            self.scrollView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EasyPopover {
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        dismiss(animated: true)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        dismiss(animated: false)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        var context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, arrowPosition.from.x, arrowPosition.from.y)
        CGContextAddLineToPoint(context, arrowPosition.pass.x, arrowPosition.pass.y)
        CGContextAddLineToPoint(context, arrowPosition.to.x, arrowPosition.to.y)
        CGContextClosePath(context)
        CGContextSetFillColorWithColor(context, self.tintColor.CGColor)
        CGContextFillPath(context)
    }
}

extension EasyPopover {
    
    private func positionFitToRect(rect: CGRect, inView view: UIView){

        // 分为上下左右四个位置，优先级： 右 <- 左 <- 下 <- 上
        
        var size = scrollView.contentSize
        
        let spaceRight  = CGRectMake((rect.origin.x + rect.size.width), 0, view.frame.width - (rect.origin.x + rect.size.width), view.frame.height)
        let spaceLeft   = CGRectMake(0, 0, rect.origin.x, view.frame.height)
        let spaceBottom = CGRectMake(0, (rect.origin.y + rect.size.height), view.frame.width, view.frame.height - (rect.origin.y + rect.size.height))
        let spaceTop    = CGRectMake(0, 0, view.frame.width, rect.origin.y)
        
        // 上、下，左、右空间较大者
        let spaceHor = spaceRight.size.width >= spaceLeft.size.width ? spaceRight : spaceLeft
        let spaceVer = spaceBottom.size.height > spaceTop.size.height ? spaceBottom : spaceTop
        
        var space: CGRect? = nil
        
        if spaceHor.size.width >= size.width + arrowSize + borderSize && spaceVer.size.height >= size.height + arrowSize + borderSize {
            // 左右空间、上下空间，都能放下，则考虑形状的影响
            let promotionDifHor = spaceHor.width / size.width - spaceHor.height / size.height
            let promotionDifVer = spaceVer.width / size.width - spaceVer.height / size.height
            space = abs(promotionDifHor) <= abs(promotionDifVer) ? spaceHor : spaceVer
        }else if spaceHor.size.width >= size.width + arrowSize + borderSize && spaceVer.size.height <= size.height + arrowSize + borderSize {
            // 左右空间可以放下，优先左右
            space = spaceHor
        }else if spaceHor.size.width <= size.width + arrowSize + borderSize && spaceVer.size.height >= size.height + arrowSize + borderSize {
            space = spaceVer
        }
        
        if space == nil {
            // 如查上下、左右都放不下，则放中间, 没有 arrow
            size.width = min(size.width, view.frame.width - borderSize * 2)
            size.height = min(size.height, view.frame.height - borderSize * 2)
            scrollView.frame.size = size
            scrollView.center = CGPointMake(view.frame.width / 2, view.frame.height / 2)
            arrowPosition.pass = scrollView.center
        }else{
            
            // 确定 arrow 方向
            var dx: CGFloat = 0, dy: CGFloat = 0
            if space!.origin.y == 0 && space!.size.height == view.frame.height{
                size.width = min(size.width, space!.width - arrowSize - borderSize)
                size.height = min(size.height, space!.height - borderSize * 2)
                scrollView.frame.size = size
                if space!.origin.x >= rect.origin.x {
                    // arrowdirection left
                    arrowPosition.pass = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height / 2)
                    arrowPosition.from = CGPointMake(arrowPosition.pass.x + arrowSize, arrowPosition.pass.y - arrowSize * 0.579)
                    arrowPosition.to = CGPointMake(arrowPosition.pass.x + arrowSize, arrowPosition.pass.y + arrowSize * 0.579)
                    scrollView.center.x = space!.origin.x + arrowSize + scrollView.frame.width / 2
                    dx = cornerRadius
                }else{
                    // arrowdirection right
                    arrowPosition.pass = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height / 2)
                    arrowPosition.from = CGPointMake(arrowPosition.pass.x - arrowSize, arrowPosition.pass.y - arrowSize * 0.579)
                    arrowPosition.to = CGPointMake(arrowPosition.pass.x - arrowSize, arrowPosition.pass.y + arrowSize * 0.579)
                    scrollView.center.x = space!.width - arrowSize - scrollView.frame.width / 2
                    dx = -cornerRadius + scrollView.frame.width
                }
                scrollView.center.y = arrowPosition.pass.y + (view.frame.height / 2 - arrowPosition.pass.y) / view.frame.height * (size.height + borderSize * 2)
                if arrowPosition.from.y < scrollView.frame.origin.y + cornerRadius {
                    arrowPosition.from = CGPointMake(scrollView.frame.origin.x + dx, scrollView.frame.origin.y)
                };if arrowPosition.to.y > scrollView.frame.origin.y + scrollView.frame.height - cornerRadius{
                    arrowPosition.to = CGPointMake(scrollView.frame.origin.x + dx, scrollView.frame.origin.y + scrollView.frame.height)
                }
            }else
            if space!.origin.x == 0 && space!.size.width == view.frame.width{
                size.width = min(size.width, space!.width - borderSize * 2)
                size.height = min(size.height, space!.height - arrowSize - borderSize)
                scrollView.frame.size = size
                if space!.origin.y >= rect.origin.y {
                    // arrowdirection up
                    arrowPosition.pass = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height)
                    arrowPosition.from = CGPointMake(arrowPosition.pass.x - arrowSize * 0.579, arrowPosition.pass.y + arrowSize)
                    arrowPosition.to = CGPointMake(arrowPosition.pass.x + arrowSize * 0.579, arrowPosition.pass.y + arrowSize)
                    scrollView.center.y = space!.origin.y + arrowSize + scrollView.frame.height / 2
                    dy = cornerRadius
                }else{
                    // arrowdirection down
                    arrowPosition.pass = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y)
                    arrowPosition.from = CGPointMake(arrowPosition.pass.x - arrowSize * 0.579, arrowPosition.pass.y - arrowSize)
                    arrowPosition.to = CGPointMake(arrowPosition.pass.x + arrowSize * 0.579, arrowPosition.pass.y - arrowSize)
                    scrollView.center.y = space!.height - arrowSize - scrollView.frame.height / 2
                    dy = -cornerRadius + scrollView.frame.height
                }
                scrollView.center.x = arrowPosition.pass.x + (view.frame.width / 2 - arrowPosition.pass.x) / view.frame.width * (size.width + borderSize * 2)
                if arrowPosition.from.x < scrollView.frame.origin.x + cornerRadius {
                    arrowPosition.from = CGPointMake(scrollView.frame.origin.x, scrollView.frame.origin.y + dy)
                };if arrowPosition.to.x > scrollView.frame.origin.x + scrollView.frame.width - cornerRadius{
                    arrowPosition.to = CGPointMake(scrollView.frame.origin.x + scrollView.frame.width , scrollView.frame.origin.y + dy)
                }
            }
        }
    }
}
