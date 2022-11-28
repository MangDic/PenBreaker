//
//  ViewController.swift
//  PenBreaker
//
//  Created by 이명직 on 2022/11/22.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    // MARK: Properties
    let disposeBag = DisposeBag()
    let shareRelay = PublishRelay<UIImage>()
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bind()
    }

    // MARK: Binding
    private func bind() {
        sketchView
            .setupDI(shareRelay: shareRelay)
        
        shareRelay.subscribe(onNext: { [weak self] image in
            guard let `self` = self else { return }
            
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            self.present(activityVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    // MARK: View
    lazy var sketchView = SketchView()
    
    private func setupLayout() {
        view.addSubview(sketchView)
        
        sketchView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

