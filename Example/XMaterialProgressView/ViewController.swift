//
//  ViewController.swift
//  XMaterialProgressView
//
//  Created by hyh on 08/16/2025.
//  Copyright (c) 2025 hyh. All rights reserved.
//

import UIKit
import XMaterialProgressView

class ViewController: UIViewController {
    
    private lazy var circleProgressView: XMaterialCircleProgressView = {
        let view = XMaterialCircleProgressView()
        return view
    }()
    
    private lazy var lineProgressView_v1: XMaterialLinearProgressView = {
        let view = XMaterialLinearProgressView()
        view.style = .plain
        return view
    }()
    
    private lazy var lineProgressView_v2: XMaterialLinearProgressView = {
        let view = XMaterialLinearProgressView()
        view.style = .bazier
        return view
    }()
    
    // MARK: - Inits
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressViews()
        setupButtons()
    }
    
    private func setupProgressViews() {
        
        view.addSubview(circleProgressView)
        view.addSubview(lineProgressView_v1)
        view.addSubview(lineProgressView_v2)
        
        let top: CGFloat = 64 + 16
        let screenWidth = UIScreen.main.bounds.width
        
        circleProgressView.frame = CGRect(x: 16, y: top, width: 100, height: 100)
        
        lineProgressView_v1.frame = CGRect(x: 16, y: top + 100 + 20 + 00, width: screenWidth - 32, height: 44)
        lineProgressView_v2.frame = CGRect(x: 16, y: top + 100 + 20 + 44, width: screenWidth - 32, height: 44)
        
        setValue(nil, animated: true)
    }
    
    private func setupButtons() {
        
        func createButton(title: String, action: Selector) -> UIButton {
            let button = UIButton(type: .custom)
            button.addTarget(self, action: action, for: .touchUpInside)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            
            view.addSubview(button)
            return button
        }
        
        let setNilButton = createButton(title: "nil", action: #selector(setToNil))
        let set0Button = createButton(title: "0", action: #selector(setTo0))
        let set25Button = createButton(title: "25", action: #selector(setTo25))
        let set50Button = createButton(title: "50", action: #selector(setTo50))
        let set75Button = createButton(title: "75", action: #selector(setTo75))
        let set100Button = createButton(title: "100", action: #selector(setTo100))

        let top = 64 + 16 + 100 + 20 + 44 + 44 + 44 + 16
        
        setNilButton.frame = CGRect(x: 16, y: top, width: 44, height: 44)
        
        set0Button.frame   = CGRect(x: 16 + (44 + 12) * 0 , y: top + 44 + 16, width: 44, height: 44)
        set25Button.frame  = CGRect(x: 16 + (44 + 12) * 1 , y: top + 44 + 16, width: 44, height: 44)
        set50Button.frame  = CGRect(x: 16 + (44 + 12) * 2 , y: top + 44 + 16, width: 44, height: 44)
        set75Button.frame  = CGRect(x: 16 + (44 + 12) * 3 , y: top + 44 + 16, width: 44, height: 44)
        set100Button.frame = CGRect(x: 16 + (44 + 12) * 4 , y: top + 44 + 16, width: 44, height: 44)
        
    }
    
    // MARK: - Events
    
    @objc private func setToNil() {
        setValue(nil, animated: true)
    }
    
    @objc private func setTo0() {
        setValue(0, animated: true)
    }
    
    @objc private func setTo25() {
        setValue(0.25, animated: true)
    }
    
    @objc private func setTo50() {
        setValue(0.50, animated: true)
    }
    
    @objc private func setTo75() {
        setValue(0.75, animated: true)
    }
    
    @objc private func setTo100() {
        setValue(1.00, animated: true)
    }
    
    private func setValue(_ value: Double?, animated: Bool) {
        circleProgressView.setValue(value, animated: animated)
        lineProgressView_v1.setValue(value, animated: animated)
        lineProgressView_v2.setValue(value, animated: animated)
    }
    
}

