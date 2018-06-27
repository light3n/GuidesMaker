//
//  StepMaker.swift
//  GuidesMaker
//
//  Created by 指道科技 on 2018/6/26.
//  Copyright © 2018年 指道科技. All rights reserved.
//

// API
// operateArea 操作区域形状
enum AreaPath {
    case rectangle
    case oval
    case custom(UIBezierPath)
}

// 连接 操作区域 与 提示语 的部分
enum Pointer {
    case line // 直线
    case dashLine // 虚线
    case curve // 曲线
    case bubble // 气泡
    case arrow // 箭头
}

// Prompt Background 提示语背景
enum PromptBackground {
    case bezierPath(UIBezierPath)
    case image(UIImage)
}

import UIKit

class StepData {
    var operateArea: CGRect?
    var prompt: String!
    var audioText: String?
    
    init(operateArea area: CGRect? = .zero, prompt: String!, audioText: String?) {
        self.operateArea = area
        self.prompt = prompt
        if audioText != nil {
            self.audioText = audioText
        } else {
            self.audioText = prompt
        }
    }
}

protocol GuidesMakerProtocol {
    
}

class StepMaker: UIView {
    
    let defaultFrame = UIScreen.main.bounds
    
    var bgView: UIView!
    
    var operateBtn: UIButton?
    
    var promptLabel: UILabel!
    
    var data: StepData!
    
    var currentGesture: UIGestureRecognizer?
    
    static func show(withOperateArea area: CGRect?, prompt: String!, audioText: String?) {
        let stepData = StepData.init(operateArea: area, prompt: prompt, audioText: audioText)
        let stepMaker = StepMaker.init(stepData: stepData)
        let window = UIApplication.shared.delegate?.window
        window??.rootViewController!.view.addSubview(stepMaker)
    }
    
    init(stepData data: StepData!) {
        super.init(frame: defaultFrame)
        self.backgroundColor = .clear
        self.data = data
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UI Configuration
    fileprivate func setupUI() {
        
        // mask bg view
        let bgView = UIView()
        bgView.alpha = 0.75
        self.addSubview(bgView)
        self.bgView = bgView
        
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(StepMaker.handleTapGestureEvent))
        self.addGestureRecognizer(tapGes)
        
        let pinchGes = UIPinchGestureRecognizer.init(target: self, action: #selector(StepMaker.handlePinchGestureEvent(_:)))
        self.addGestureRecognizer(pinchGes)
        
        // prompt label
        let promptLabel = UILabel()
        promptLabel.numberOfLines = 0
        promptLabel.textColor = .white
        promptLabel.backgroundColor = .clear
        promptLabel.font = UIFont.systemFont(ofSize: 18)
        promptLabel.textAlignment = .center
        promptLabel.layer.borderColor = UIColor.white.cgColor
        promptLabel.layer.borderWidth = 2
        promptLabel.text = data.prompt
        self.addSubview(promptLabel)
        self.promptLabel = promptLabel
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.bgView.frame = self.bounds
        
        let fullPath = UIBezierPath.init(rect: self.frame)
        if let area = self.data.operateArea, !area.equalTo(.zero) {
            let clipPath = UIBezierPath.init(ovalIn: (self.data.operateArea)!)
            fullPath.append(clipPath)
        }
        
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.path = fullPath.cgPath
        shapeLayer.fillColor = UIColor.black.cgColor
        self.bgView.layer.addSublayer(shapeLayer)
        
        if let area = self.data.operateArea, !area.equalTo(.zero) {
            self.promptLabel.frame = CGRect.init(x: 100, y: (self.data?.operateArea?.maxY)!+30, width: 200, height: 40)
        } else {
            self.promptLabel.frame = CGRect.init(x: 100, y: 100, width: 200, height: 40)
        }
        self.promptLabel.sizeToFit()
        let frame = self.promptLabel.frame
        let adjustedFrame = frame.insetBy(dx: -20, dy: -6).offsetBy(dx: -10, dy: -3)
        self.promptLabel.frame = adjustedFrame
        
        
    }
    
    // MARK: - Event Handler
    
    @objc fileprivate func handleTapGestureEvent() {
        print("-handleTapGestureEvent(_:)")
        self.removeFromSuperview()
    }
    @objc fileprivate func handlePinchGestureEvent(_ ges: UIPinchGestureRecognizer) {
        print("-handlePinchGestureEvent(_:):\(ges.scale)")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        guard let area = self.data.operateArea, !area.equalTo(.zero) else {
            return true
        }
        if area.contains(point) {
            return true
        } else {
            return false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first?.location(in: self)
        print("touchesBegan:\(point!)")
        self.bgView.isHidden = true
        self.promptLabel.isHidden = true
        
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first?.location(in: self)
        print("touchesMoved:\(point!)")
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.bgView.isHidden = false
        self.promptLabel.isHidden = false
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}




