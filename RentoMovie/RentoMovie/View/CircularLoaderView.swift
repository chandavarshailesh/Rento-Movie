//
//  CircularLoaderView.swift
//  RentoMovie
//
//  Created by Shailesh.Chandavar on 07/12/18.
//  Copyright © 2018 Shailesh.Chandavar. All rights reserved.
//

import Foundation
import UIKit

/// CircularLoaderView is a designable loader which animates with the help of stroke.
@IBDesignable
class CircularLoaderView: UIView {
    
    @IBInspectable var startAngle: CGFloat = 0.0
    @IBInspectable var endAngle: CGFloat = 0.0
    @IBInspectable var innerCircleLineWidth: CGFloat = 0.0
    @IBInspectable var circleLineWidth: CGFloat = 0.0
    weak var animationDelegate: CAAnimationDelegate?
    
    
    private let circlularAnimation = "drawCircleAnimation"
    private let animationId = "animationId"
    
    private let circlePathLayer = CAShapeLayer()
    private let innerCirclePathLayer = CAShapeLayer()
    
    private func configureCicrcleLayer() {
        configure(circleLayer: innerCirclePathLayer)
        configure(circleLayer: circlePathLayer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCicrcleLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isHidden = true
    }
    
    override func awakeFromNib() {
        configureCicrcleLayer()
    }
    
    //Circular loader animation
    func revealInDuration(animationDuration:TimeInterval){
        let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        isHidden = false
        drawAnimation.duration = animationDuration
        drawAnimation.delegate = animationDelegate
        drawAnimation.fromValue = (0)
        drawAnimation.toValue = (1)
        drawAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        drawAnimation.setValue(circlularAnimation, forKey: animationId)
        circlePathLayer.add(drawAnimation, forKey:circlularAnimation )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
        innerCirclePathLayer.frame = bounds
        innerCirclePathLayer.path = innerCirclePath().cgPath
    }
    
    //Congiguring with stroke
    private func configure(circleLayer: CAShapeLayer) {
        circleLayer.frame = bounds
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.lineWidth = circleLayer == innerCirclePathLayer ? innerCircleLineWidth : circleLineWidth
        circleLayer.strokeStart = 0.0
        circleLayer.strokeEnd = 1.0
        circleLayer.contentsScale = UIScreen.main.scale
        circleLayer.rasterizationScale = UIScreen.main.scale
        circleLayer.shouldRasterize = true
        layer.addSublayer(circleLayer)
        
    }
    //Creating bezierpath
    private func circlePath() -> UIBezierPath {
        let midpoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let bezierPath = UIBezierPath(arcCenter:midpoint, radius:(self.bounds.size.width * 0.5) - (circleLineWidth - innerCircleLineWidth - 2), startAngle: startAngle, endAngle: endAngle, clockwise:true)
        return bezierPath
    }
    
    private func innerCirclePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: self.bounds)
    }
    
}
