//
//  XMaterialLinearProgressView.swift
//  XMaterialProgressView
//
//  Created by hyh on 2025/7/18.
//

import UIKit

public class XMaterialLinearProgressView: UIView {
    
    public enum Style {
        case plain
        case bazier
    }
    
    // MARK: - Layers
    
    private lazy var trackLayer: CAShapeLayer = {
        let layer = makeLineLayer(color: trackColor)
        return layer
    }()
    
    private lazy var segmentLayer1: CAShapeLayer = {
        let layer = makeLineLayer(color: color)
        return layer
    }()
    
    private lazy var segmentLayer2: CAShapeLayer = {
        let layer = makeLineLayer(color: color)
        return layer
    }()
    
    // MARK: - Public Properties
    
    public var trackColor: UIColor = .clear {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }
    
    public var color: UIColor = .systemBlue {
        didSet {
            segmentLayer1.strokeColor = color.cgColor
            segmentLayer2.strokeColor = color.cgColor
        }
    }
    
    public var width: Double = 4 {
        didSet {
            [trackLayer, segmentLayer1, segmentLayer2].forEach { $0.lineWidth = width }
            setNeedsLayout()
        }
    }
    
    private var _value: Double?
    
    public var value: Double? {
        get { _value }
        set {
            let old = _value
            _value = newValue
            resetAnimation(oldValue: old, newValue: newValue, animated: false)
        }
    }
    
    public func setValue(_ value: Double?, animated: Bool) {
        let old = _value
        _value = value
        resetAnimation(oldValue: old, newValue: value, animated: animated)
    }
    
    public var style: Style = .bazier {
        didSet {
            resetAnimation(oldValue: nil, newValue: nil, animated: false)
        }
    }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        layer.addSublayer(trackLayer)
        layer.addSublayer(segmentLayer1)
        layer.addSublayer(segmentLayer2)
        resetAnimation(oldValue: nil, newValue: nil, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        segmentLayer1.removeAllAnimations()
        segmentLayer2.removeAllAnimations()
    }
    
    // MARK: - Layout
    
    private var lastBounds: CGRect = .zero
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds != lastBounds else { return }
        lastBounds = bounds
        
        let path = linePath(size: bounds.size)
        trackLayer.frame = bounds
        trackLayer.path = path.cgPath
        
        // layer1
        segmentLayer1.frame = bounds
        segmentLayer1.path = path.cgPath
        
        // layer2
        segmentLayer2.frame = bounds
        segmentLayer2.path = path.cgPath
    }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: 200, height: width)
    }
    
    // MARK: - Layer builder
    
    private func makeLineLayer(color: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.strokeColor = color.cgColor
        layer.fillColor = nil
        layer.lineCap = .round
        layer.lineWidth = width
        layer.strokeStart = 0
        layer.strokeEnd = 0
        return layer
    }
    
    private func linePath(size: CGSize) -> UIBezierPath {
        let y = size.height / 2
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: size.width, y: y))
        return path
    }
    
    // MARK: - Animation
    
    private func resetAnimation(oldValue: Double?, newValue: Double?, animated: Bool) {
        [segmentLayer1, segmentLayer2].forEach { $0.removeAllAnimations() }
        // 进度模式
        if let value = newValue {
            let fromValue = (oldValue ?? 0)
            let toValue = value
            segmentLayer1.strokeStart = 0
            segmentLayer1.strokeEnd = toValue
            if value > 0 && animated {
                segmentLayer1.add(progressAnimation(fromValue: fromValue, toValue: toValue), forKey: "progress_animation")
            } else {
                segmentLayer1.removeAllAnimations()
            }
            segmentLayer2.strokeStart = 0
            segmentLayer2.strokeEnd = 0
            segmentLayer2.isHidden = true
        }
        // 动画模式
        else {
            segmentLayer1.strokeEnd = 0
            segmentLayer2.strokeEnd = 0
            segmentLayer2.isHidden = false
            addIndeterminateBarAnimation(layer1: segmentLayer1, layer2: segmentLayer2)
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
    
    private func addIndeterminateBarAnimation(layer1: CAShapeLayer, layer2: CAShapeLayer) {
        
        switch style {
        case .plain:
            XMaterialLinearProgressAnimationPlain.addIndeterminateBarAnimation(layer1: layer1, layer2: layer2)
        case .bazier:
            XMaterialLinearProgressAnimationBazierExact.addIndeterminateBarAnimation(layer1: layer1, layer2: layer2)
        }
    }
}

// swiftlint:disable identifier_name function_body_length

let _kIndeternunateLinearDurationSecond: CFTimeInterval = 1.8 // 1800ms
let _kIndeterminateLinearDuration: Double = _kIndeternunateLinearDurationSecond * 1000

private class XMaterialLinearProgressAnimationPlain {
    
    static func makeKeyframe(_ times: [CGFloat], _ values: [CGFloat], keyPath: String) -> CAKeyframeAnimation {
        let anim = CAKeyframeAnimation(keyPath: keyPath)
        anim.keyTimes = times.map { NSNumber(value: Float($0)) }
        anim.values = values
        anim.duration = _kIndeternunateLinearDurationSecond
        anim.calculationMode = .cubic
        return anim
    }
    
    static func addIndeterminateBarAnimation(layer1: CAShapeLayer, layer2: CAShapeLayer) {
        
        let line1HeadStart: CGFloat = 0.0
        let line1HeadEnd: CGFloat = 750.0 / _kIndeterminateLinearDuration
        let line1TailStart: CGFloat = 333.0 / _kIndeterminateLinearDuration
        let line1TailEnd: CGFloat = (333.0 + 750.0) / _kIndeterminateLinearDuration
        let line2HeadStart: CGFloat = 1000.0 / _kIndeterminateLinearDuration
        let line2HeadEnd: CGFloat = (1000.0 + 567.0) / _kIndeterminateLinearDuration
        let line2TailStart: CGFloat = 1267.0 / _kIndeterminateLinearDuration
        let line2TailEnd: CGFloat = (1267.0 + 533.0) / _kIndeterminateLinearDuration
        
        let head1 = makeKeyframe(
            [line1HeadStart, line1HeadEnd],
            [0.0, 1.0],
            keyPath: "strokeEnd"
        )
        let tail1 = makeKeyframe(
            [line1TailStart, line1TailEnd],
            [0.0, 1.0],
            keyPath: "strokeStart"
        )
        let head2 = makeKeyframe(
            [line2HeadStart, line2HeadEnd],
            [0.0, 1.0],
            keyPath: "strokeEnd"
        )
        let tail2 = makeKeyframe(
            [line2TailStart, line2TailEnd],
            [0.0, 1.0],
            keyPath: "strokeStart"
        )
        
        let group1 = CAAnimationGroup()
        group1.animations = [head1, tail1]
        group1.duration = _kIndeternunateLinearDurationSecond
        group1.repeatCount = .infinity
        group1.fillMode = .forwards
        group1.isRemovedOnCompletion = false
        layer1.add(group1, forKey: "indeterminate1")
        let group2 = CAAnimationGroup()
        group2.animations = [head2, tail2]
        group2.duration = _kIndeternunateLinearDurationSecond
        group2.repeatCount = .infinity
        group2.fillMode = .forwards
        group2.isRemovedOnCompletion = false
        layer2.add(group2, forKey: "indeterminate2")
    }
}

private class XMaterialLinearProgressAnimationBazierExact {
    
    // 参考
    // ~/flutter_sdk/flutter/packages/flutter/lib/src/material/progress_indicator.dart
    // ~/flutter_sdk/flutter/packages/flutter/lib/src/animation/curves.dart
    
    struct Cubic {
        let a: Double
        let b: Double
        let c: Double
        let d: Double
        
        init(_ a: Double, _ b: Double, _ c: Double, _ d: Double) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
        }
        
        let _cubicErrorBound: Double = 0.001
        
        func _evaluateCubic(_ a: Double, _ b: Double, _ m: Double) -> Double {
            return 3 * a * (1 - m) * (1 - m) * m + 3 * b * (1 - m) * m * m + m * m * m;
        }
        
        // 二分法求解
        func transformInternal(_ t: Double) -> Double {
            var start = 0.0
            var end = 1.0
            while true {
                let midpoint = (start + end) / 2
                let estimate = _evaluateCubic(a, c, midpoint)
                if abs(t - estimate) < _cubicErrorBound {
                    return _evaluateCubic(b, d, midpoint)
                }
                if estimate < t {
                    start = midpoint
                } else {
                    end = midpoint
                }
            }
        }
    }
    
    
    static func transformInternal(_ t: Double, _ begin: Double, _ end: Double, _ curve: Cubic) -> Double {
        if t <= begin { return 0 }
        if t >= end { return 1 }
        let progress = (t - begin) / (end - begin)
        return curve.transformInternal(progress)
    }
    
    static func makeAnimation(_ begin: Double, _ end: Double, curve: Cubic, keyPath: String) -> CAKeyframeAnimation {
        let anim = CAKeyframeAnimation(keyPath: keyPath)
        var values: [CGFloat] = []
        var keyTimes: [NSNumber] = []

        let frames = 60
        
        for i in 0...frames {
            let t = Double(i) / Double(frames)
            let transformed = transformInternal(t, begin, end, curve)
            values.append(CGFloat(transformed))
            keyTimes.append(NSNumber(value: t))
        }

        anim.values = values
        anim.keyTimes = keyTimes
        anim.duration = _kIndeternunateLinearDurationSecond
        anim.repeatCount = .infinity
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false

        return anim
    }
    
    static func addIndeterminateBarAnimation(layer1: CAShapeLayer, layer2: CAShapeLayer) {

        let head1 = makeAnimation(
            0.0,
            750.0 / _kIndeterminateLinearDuration,
            curve: Cubic(0.2, 0.0, 0.8, 1.0),
            keyPath: "strokeEnd"
        )
        let tail1 = makeAnimation(
            333.0 / _kIndeterminateLinearDuration,
            (333.0 + 750.0) / _kIndeterminateLinearDuration,
            curve: Cubic(0.4, 0.0, 1.0, 1.0),
            keyPath: "strokeStart"
        )
        let head2 = makeAnimation(
            1000.0 / _kIndeterminateLinearDuration,
            (1000.0 + 567.0) / _kIndeterminateLinearDuration,
            curve: Cubic(0.0, 0.0, 0.65, 1.0),
            keyPath: "strokeEnd"
        )
        let tail2 = makeAnimation(
            1267.0 / _kIndeterminateLinearDuration,
            (1267.0 + 533.0) / _kIndeterminateLinearDuration,
            curve: Cubic(0.10, 0.0, 0.45, 1.0),
            keyPath: "strokeStart"
        )

        let group1 = CAAnimationGroup()
        group1.animations = [head1, tail1]
        group1.duration = _kIndeternunateLinearDurationSecond
        group1.repeatCount = .infinity
        group1.fillMode = .forwards
        group1.isRemovedOnCompletion = false
        layer1.add(group1, forKey: "indeterminate1")
        let group2 = CAAnimationGroup()
        group2.animations = [head2, tail2]
        group2.duration = _kIndeternunateLinearDurationSecond
        group2.repeatCount = .infinity
        group2.fillMode = .forwards
        group2.isRemovedOnCompletion = false
        layer2.add(group2, forKey: "indeterminate2")
    }
}

// swiftlint:enable identifier_name function_body_length
