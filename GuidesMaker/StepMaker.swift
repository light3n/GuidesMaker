//
//  StepMaker.swift
//  GuidesMaker
//
//  Created by 指道科技 on 2018/6/26.
//  Copyright © 2018年 指道科技. All rights reserved.
//

import UIKit

/**
 Feature：
 - 一行代码部署一个、多个引导页面
 - 支持一系列、具备连贯性的操作的引导（应用场景：图像编辑App中一个连贯性的编辑操作）
 - 支持手势事件传递，为了降低 引导框架 与 需要引导的内容控制器 之间的耦合性，提供了相应的回调 API，Controller 可以通过实现 API 来获得手势回调，回调事件交由 Controller 自行管理（应用场景：在引导页面不消失的情况下，同步更新 Controller 的状态、事件）
 - 支持自定义界面UI：操作区域、Prompt 提示语
 - 支持语音朗读提示语
 
 - 传入某个 view 或者坐标 rect，框架自动根据 rect 识别需要响应的对象
 
 - 支持指定任意view（cell、barButtonItem、titleView）作为区域限定
 - 支持常用手势演示：移动、缩放、上下左右滑动（因此，需要将 Prompt 及箭头抽离封装成一个部件）
 - 支持关闭操作区域限定，只作为普通引导
 */

/// UI
// operateArea 操作区域形状
enum AreaPath {
    case rectangle
    case oval
    case custom(UIBezierPath)
}


// Prompt Background 提示语背景
enum PromptBackground {
    case bezierPath(UIBezierPath)
    case image(UIImage)
}

/// Event
// 实现多选 enum 的方法：
// 1. OptionSet @link https://stackoverflow.com/questions/24066170/how-to-create-ns-options-style-bitmask-enumerations-in-swift/24066171#24066171 /@link
// 2. 数组包装 enum -> [Type]
enum Gesture {
    case tap
    case pan(targetPoint: CGPoint)
    case pinch(targetScale: CGFloat)
    case rotate(targetAngle: CGFloat)
}

/// 配置项
class StepData {
    var operateArea: CGRect?
    var prompt: String!
    
    init(operateArea area: CGRect? = .zero, prompt: String!) {
        self.operateArea = area
        self.prompt = prompt
    }
}


/// 回调 API
protocol GuidesMakerDelegate {
    func stepMaker(_ maker: StepMaker?, didReceivedGestureEvent gesture: UIGestureRecognizer?) -> Void
}

class StepMaker: UIView {
    
    let defaultFrame = UIScreen.main.bounds
    
    var bgView: UIView!
    
    var operateBtn: UIButton?
    
    var promptLabel: UILabel!
    
    var data: StepData!
    
    var currentGesture: UIGestureRecognizer?
    
    var delegate: GuidesMakerDelegate?
    
    static func show(withOperateArea area: CGRect? = CGRect.zero, prompt: String!, delegate: GuidesMakerDelegate) {
        let stepData = StepData.init(operateArea: area, prompt: prompt)
        let stepMaker = StepMaker.init(stepData: stepData)
        stepMaker.delegate = delegate
        let window = UIApplication.shared.delegate?.window
        window??.rootViewController?.view.addSubview(stepMaker)
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
        
//        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(StepMaker.handleTapGestureEvent(_:)))
//        bgView.addGestureRecognizer(tapGes)
//
//        let panGes = UIPanGestureRecognizer.init(target: self, action: #selector(StepMaker.handlePanGestureEvent(_:)))
//        bgView.addGestureRecognizer(panGes)
//
//        let pinchGes = UIPinchGestureRecognizer.init(target: self, action: #selector(StepMaker.handlePinchGestureEvent(_:)))
//        bgView.addGestureRecognizer(pinchGes)
        
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
    
    @objc fileprivate func handleTapGestureEvent(_ gesture: UITapGestureRecognizer) {
        print("-handleTapGestureEvent(_:)")
        self.removeFromSuperview()
        self.delegate?.stepMaker(self, didReceivedGestureEvent: gesture)
    }
    @objc fileprivate func handlePanGestureEvent(_ gesture: UIPanGestureRecognizer) {
        print("-handlePanGestureEvent(_:):\(String(describing: gesture.location(in: nil)))")
        self.delegate?.stepMaker(self, didReceivedGestureEvent: gesture)
        if gesture.state == .ended {
            let rect: CGRect = CGRect.init(x: 0, y: 500, width: 100, height: 100)
            if rect.contains(gesture.location(in: nil)) {
                self.removeFromSuperview()
            } else {
                self.bgView.isHidden = false
                self.promptLabel.isHidden = false
            }
        }
    }
    @objc fileprivate func handlePinchGestureEvent(_ gesture: UIPinchGestureRecognizer) {
        print("-handlePinchGestureEvent(_:):\(gesture.scale)")
        self.delegate?.stepMaker(self, didReceivedGestureEvent: gesture)
        if gesture.state == .ended {
            if gesture.scale > 3 {
                self.removeFromSuperview()
            } else {
                self.bgView.isHidden = false
                self.promptLabel.isHidden = false
            }
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        guard let area = self.data.operateArea, !area.equalTo(.zero) else {
            return true
        }
        print("-pointInside:")
        if area.contains(point) {
            
            self.bgView.isHidden = true
            self.promptLabel.isHidden = true
            
            return false
        } else {
            return true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first?.location(in: self)
        print("touchesBegan:\(point!)")
//        self.bgView.isHidden = true
//        self.promptLabel.isHidden = true
        
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first?.location(in: self)
//        print("touchesMoved:\(point!)")
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.bgView.isHidden = false
        self.promptLabel.isHidden = false
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}




