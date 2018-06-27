//
//  ViewController.swift
//  GuidesMaker
//
//  Created by 指道科技 on 2018/6/26.
//  Copyright © 2018年 指道科技. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let button = UIButton()
        button.backgroundColor = .green
        button.setTitle("Design", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.frame = CGRect.init(x: 150, y: 200, width: 120, height: 60)
        self.view .addSubview(button)
        
        StepMaker.show(withOperateArea: button.frame, prompt: "点击按钮进入图像编辑功能", audioText: nil)
        
        Demo.calculate { (maker) in
            print(maker.add(5).add(2).count ?? 0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class Demo {
    var count: Int? = 0
    
    static func calculate(maker: (Demo) -> ()) {
        let demo = Demo()
        maker(demo)
    }
    
    func add(_ num: Int) -> Demo {
        self.count? += num
        return self
    }
}

