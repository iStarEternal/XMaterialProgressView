//
//  XMaterialCircleProgressView.swift
//  XMaterialProgressView
//
//  Created by hyh on 2025/3/3.
//

import Foundation
import UIKit

/// 一种Material的Loading + Progress样式
/// 动画参考：https://github.com/relatedcode/ProgressHUD
/// 可用其他参考：https://github.com/ninjaprox/NVActivityIndicatorView
public class XMaterialCircleProgressView: UIView {
    
    private lazy var trackLayer: CAShapeLayer = {
        let layer = circleStrokeLayer(size: bounds.size, color: trackColor, width: width)
        return layer
    }()
    
    private lazy var valueLayer: CAShapeLayer = {
        let layer = circleStrokeLayer(size: bounds.size, color: color, width: width)
        return layer
    }()
    
    private var lastBounds: CGRect = .zero
    
    public var trackColor: UIColor = .clear { // MaterialColorPalettes.grey.shade50
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    public var color: UIColor = .systemBlue {
        didSet {
            valueLayer.strokeColor = color.cgColor
        }
    }
    
    public var width: CGFloat = 4 {
        didSet {
            trackLayer.lineWidth = width
            valueLayer.lineWidth = width
        }
    }
    
    var _value: Double?
    
    /// 值为nil的时候，开启spin动画，有规律的改变长短，并且旋转的Loading。
    /// 值为数字的时候，为从12点开始的，顺时针的进度条
    public var value: Double? {
        get {
            _value
        }
        set {
            let _oldValue = _value
            let _newValue = newValue
            _value = _newValue
            resetAnimation(oldValue: _oldValue, newValue: _newValue, animated: false)
        }
    }
    
    public func setValue(_ value: Double?, animated: Bool) {
        
        let _oldValue = _value
        let _newValue = value
        _value = _newValue
        resetAnimation(oldValue: _oldValue, newValue: _newValue, animated: animated)
    }
    
    // MARK: -
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(trackLayer)
        layer.addSublayer(valueLayer)
        resetAnimation(oldValue: nil, newValue: nil, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        valueLayer.removeAllAnimations()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds != lastBounds else { return }
        lastBounds = bounds
        trackLayer.frame = bounds
        trackLayer.path = circlePath(size: bounds.size).cgPath
        valueLayer.frame = bounds
        valueLayer.path = circlePath(size: bounds.size).cgPath
    }
    
    /// 默认尺寸 44x44
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 44, height: 44)
    }
    
    // MARK: -
    
    private func resetAnimation(oldValue: Double?, newValue: Double?, animated: Bool) {
        valueLayer.removeAllAnimations()
        // 进度模式
        if let value = newValue {
            let fromValue = (oldValue ?? 0)
            let toValue = value
            valueLayer.transform = CATransform3DMakeRotation(-Double.pi / 2, 0, 0, 1)
            valueLayer.strokeStart = 0
            valueLayer.strokeEnd = toValue
            if toValue > 0 && animated {
                valueLayer.add(progressAnimation(fromValue: fromValue, toValue: toValue), forKey: "progress_animation")
            } else {
                valueLayer.removeAllAnimations()
            }
        }
        // 动画模式
        else {
            valueLayer.transform = CATransform3DMakeRotation(-Double.pi / 2, 0, 0, 1)
            valueLayer.strokeStart = 0
            valueLayer.strokeEnd = 1
            valueLayer.add(spinAnimation(), forKey: "rotation_animation")
        }
    }
    
    private func progressAnimation(fromValue: Double, toValue: Double) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.15
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    private func spinAnimation() -> CAAnimation {
        let beginTime        = 0.5
        let durationStart    = 0.8 + beginTime
        let durationStop    = 0.8
        
        let animationRotation = CABasicAnimation(keyPath: "transform.rotation")
        animationRotation.byValue = 2 * Float.pi
        animationRotation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let animationStart = CABasicAnimation(keyPath: "strokeStart")
        animationStart.duration = durationStart
        animationStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1)
        animationStart.fromValue = 0
        animationStart.toValue = 1
        animationStart.beginTime = beginTime
        animationStart.fillMode = .forwards
        animationStart.isRemovedOnCompletion = false
        
        let animationStop = CABasicAnimation(keyPath: "strokeEnd")
        animationStop.duration = durationStop
        animationStop.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1)
        animationStop.fromValue = 0
        animationStop.toValue = 1
        animationStop.fillMode = .forwards
        animationStop.isRemovedOnCompletion = false
        
        let animation = CAAnimationGroup()
        animation.animations = [
            animationRotation,
            animationStop,
            animationStart,
        ]
        animation.duration = durationStart + beginTime
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        return animation
    }
    
    private func circleStrokeLayer(size: CGSize, color: UIColor, width: CGFloat) -> CAShapeLayer {
        let rect = CGRect(origin: .zero, size: size)
        let layer = CAShapeLayer()
        layer.frame = rect
        layer.path = circlePath(size: size).cgPath
        layer.fillColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = width
        layer.lineCap = .round
        return layer
    }
    
    private func circlePath(size: CGSize) -> UIBezierPath {
        // let width = size.width
        // let height = size.height
        // let center = CGPoint(x: width / 2, y: height / 2)
        // let path = UIBezierPath(arcCenter: center, radius: width / 2, startAngle: -0.5 * .pi, endAngle: 1.5 * .pi, clockwise: true)
        let path = UIBezierPath.init(ovalIn: CGRect(origin: .zero, size: size))
        return path
    }
}
