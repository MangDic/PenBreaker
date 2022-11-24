//
//  ViewController.swift
//  PenBreaker
//
//  Created by 이명직 on 2022/11/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }


    lazy var sketchView = SketchView()
    
    private func setupLayout() {
        view.addSubview(sketchView)
        
        sketchView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

