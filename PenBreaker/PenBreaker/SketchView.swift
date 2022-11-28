//
//  SketchView.swift
//  PenBreaker
//
//  Created by 이명직 on 2022/11/22.
//

import Foundation
import PencilKit
import UIKit
import SnapKit
import Then
import RxCocoa
import RxSwift

class SketchView: UIView, PKCanvasViewDelegate {
    // MARK: Properties
    let disposeBag = DisposeBag()
    
    let shareRelay = PublishRelay<UIImage>()
    
    var bottomInset: CGFloat = 0.0
    var sizeBtnArr = [UIButton]()
    
    let menuSelectedRelay = PublishRelay<ToolData>()
    var currentInkingTool = PKInkingTool(.pen, color: .black, width: 5)
    
    var menuColor = #colorLiteral(red: 0.6945146918, green: 0.5492494106, blue: 0.9612906575, alpha: 1)
    var colorArr: [UIColor] = [#colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)]
    var currentBtn: UIButton?
    
    var isDrawingMode = false
    var toolBtnSelected = false
    var sizeBtnSeleted = false
    var penTypeBtnSeleted = false
    var colorBtnSeleted = false
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupCanvas()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Dependency Injection
    func setupDI(shareRelay: PublishRelay<UIImage>) {
        self.shareRelay.bind(to: shareRelay).disposed(by: disposeBag)
    }
    
    // MARK: Binding
    private func bind() {
        menuSelectedRelay.subscribe(onNext: { [weak self] data in
            guard let `self` = self else { return }
            var ink = self.currentInkingTool.ink.inkType
            var color = self.currentInkingTool.color
            var width = self.currentInkingTool.width
            switch data.type {
            case .ink:
                ink = data.value as! PKInkingTool.InkType
                self.penTypeBtn.setTitle("\(ink)", for: .normal)
                self.penTypeBtnSeleted = false
                self.hideSelectView(animateView: self.penSelectView)
            case .color:
                color = data.value as! UIColor
            case .width:
                width = data.value as! CGFloat
                
                self.sizeBtn.setTitle("\(Int(width))px", for: .normal)
                self.sizeBtnSeleted = false
                self.hideSelectView(animateView: self.sizeSelectView)
            }
            self.currentInkingTool = PKInkingTool(ink, color: color, width: width)
            self.canvasView.tool = self.currentInkingTool
        }).disposed(by: disposeBag)
    }
    
    // MARK: Method
    private func setupCanvas() {
        // 손가락 사용을 허용합니다.
        canvasView.allowsFingerDrawing = true
        // 펜의 디폴트 값 설정
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 50)
        canvasView.delegate = self
        let p = PKToolPicker()
        p.setVisible(true, forFirstResponder: canvasView)
        p.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        guard let btn = currentBtn else { return }
        changeColor(tag: 0, btn: btn)
    }
    
    /// animateView를 보여줍니다. baseView 프레임 높이만큼 올립니다.
    private func showSelectView(animateView: UIView, baseView: UIView, hiddenFlag: Bool = true, isMenuView: Bool = false) {
        var height: CGFloat = -baseView.frame.height + bottomInset
        if isMenuView {
            height = -toolView.frame.height + bottomInset
        }
        UIView.animate(withDuration: 0.4, delay: 0, animations: {
            animateView.isHidden = false
            animateView.alpha = 1.0
            animateView.transform = CGAffineTransform(translationX: 0, y:  height)
        })
    }
    
    /// animateView를 숨깁니다.
    private func hideSelectView(animateView: UIView, hiddenFlag: Bool = true) {
        UIView.animate(withDuration: 0.4, delay: 0, animations: {
            animateView.alpha = hiddenFlag ? 0.0 : 1.0
            animateView.transform = .identity
        }, completion: { _ in
            animateView.isHidden = hiddenFlag
        })
    }
    
    private func changeColor(tag: Int, btn: UIButton) {
        guard let _ = self.currentBtn else { return }
        self.currentBtn!.backgroundColor = #colorLiteral(red: 0.9464568496, green: 0.9583716989, blue: 0.9581621289, alpha: 1)
        btn.backgroundColor = .lightGray
        self.currentBtn! = btn
        menuSelectedRelay.accept(ToolData(type: .color, value: colorArr[tag]))
    }
    
    private func changeDrawingMode() {
        canvasView.tool = isDrawingMode ? currentInkingTool : PKEraserTool(.bitmap)
    }
    
    private func safeAreaBottomInset() -> CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            return bottomPadding ??  0.0
        } else {
            return 0.0
        }
    }
    
    private func setBottomInset() {
        bottomInset = safeAreaBottomInset()
    }
    
    private func changeDrawingBtnBackground() {
        let penColor = isDrawingMode ? #colorLiteral(red: 0.8841331601, green: 0.8952633739, blue: 0.8950676322, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let eraserColor = !isDrawingMode ? #colorLiteral(red: 0.8841331601, green: 0.8952633739, blue: 0.8950676322, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        penBtn.backgroundColor = penColor
        eraserBtn.backgroundColor = eraserColor
    }
    
    private func share() {
        guard let image = canvasView.transfromToImage() else { return }
        self.shareRelay.accept(image)
    }
    
    private func download() {
        guard let image = canvasView.transfromToImage() else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    // MARK: View
    lazy var canvasView = PKCanvasView(frame: self.bounds).then {
        $0.backgroundColor = #colorLiteral(red: 1, green: 0.9518870711, blue: 0.8127006888, alpha: 1)
    }
    
    lazy var doBtnStack = UIStackView()
    
    lazy var undoBtn = UIButton().then {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "arrow.uturn.backward", withConfiguration: largeConfig)
        $0.setImage(largeBoldDoc, for: .normal)
        $0.tintColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            guard let canUndo = self.undoManager?.canUndo else { return }
            if canUndo {
                self.undoManager?.undo()
            }
        }).disposed(by: disposeBag)
    }
    
    lazy var redoBtn = UIButton().then {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "arrow.uturn.right", withConfiguration: largeConfig)
        $0.setImage(largeBoldDoc, for: .normal)
        $0.tintColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            guard let canRedo = self.undoManager?.canRedo else { return }
            if canRedo {
                self.undoManager?.redo()
            }
        }).disposed(by: disposeBag)
    }
    
    lazy var toolBtn = UIButton().then { btn in
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold, scale: .large)
        let upImage = UIImage(systemName: "chevron.up", withConfiguration: largeConfig)
        let downImage = UIImage(systemName: "chevron.down", withConfiguration: largeConfig)
        
        btn.layer.cornerRadius = 10
        btn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        btn.backgroundColor = #colorLiteral(red: 0.8751407862, green: 0.8861578107, blue: 0.8859640956, alpha: 1)
        btn.setImage(upImage, for: .normal)
        btn.setImage(downImage, for: .selected)
        btn.tintColor = .white
        btn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.toolBtnSelected = !self.toolBtnSelected
                btn.isSelected = self.toolBtnSelected
                self.setBottomInset()
                
                self.toolBtnSelected ? self.showSelectView(animateView: self.toolView, baseView: self.toolView, hiddenFlag: false) : self.hideSelectView(animateView: self.toolView, hiddenFlag: false)
                
                self.toolBtnSelected ? self.showSelectView(animateView: btn, baseView: self.toolView, hiddenFlag: false) : self.hideSelectView(animateView: btn, hiddenFlag: false)
                
                self.penSelectView.isHidden = true
                self.sizeSelectView.isHidden = true
            }).disposed(by: disposeBag)
    }
    
    lazy var toolView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 40
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    lazy var toolStack = UIStackView().then {
        $0.spacing = 10
        $0.backgroundColor = .white
    }
    
    lazy var sizeBtn = UIButton().then { btn in
        btn.setTitle("5px", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        btn.layer.cornerRadius = 4
        btn.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        btn.layer.borderWidth = 2
        btn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.sizeBtnSeleted = !self.sizeBtnSeleted
                
                self.sizeBtnSeleted ? self.showSelectView(animateView: self.sizeSelectView, baseView: btn, isMenuView: true) : self.hideSelectView(animateView: self.sizeSelectView)
            }).disposed(by: disposeBag)
    }
    
    lazy var sizeSelectView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.backgroundColor = .white
        $0.alpha = 0.0
        $0.isHidden = true
        let menuArr: [CGFloat] = [5, 7, 10, 15, 20, 30]
        
        let stack = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 3
        }
        
        $0.addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        var index = 0
        for menu in menuArr {
            let btn = UIButton().then {
                $0.setTitle("\(Int(menu))px", for: .normal)
                $0.setTitleColor(.lightGray, for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
                $0.rx.tap.subscribe(onNext: {
                    self.currentInkingTool.width = menu
                    self.menuSelectedRelay.accept(ToolData(type: .width, value: menu))
                }).disposed(by: disposeBag)
            }
            self.sizeBtnArr.append(btn)
            
            stack.addArrangedSubview(btn)
            btn.snp.makeConstraints {
                $0.height.equalTo(30)
            }
            index += 1
        }
    }
    
    lazy var penTypeBtn = UIButton().then { btn in
        btn.setTitle("pen", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        btn.layer.cornerRadius = 4
        btn.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        btn.layer.borderWidth = 2
        btn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.penTypeBtnSeleted = !self.penTypeBtnSeleted
                
                self.penTypeBtnSeleted ? self.showSelectView(animateView: self.penSelectView, baseView: btn, isMenuView: true) : self.hideSelectView(animateView: self.penSelectView)
            }).disposed(by: disposeBag)
    }
    
    lazy var penSelectView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.backgroundColor = .white
        $0.alpha = 0.0
        $0.isHidden = true
        
        var menuArr: [PKInkingTool.InkType] = [.pen, .pencil, .marker]
        
        let stack = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 5
        }
        
        $0.addSubview(stack)
        
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        var index = 0
        for menu in menuArr {
            let btn = UIButton().then {
                $0.setTitle("\(menu)", for: .normal)
                $0.setTitleColor(.lightGray, for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
                $0.rx.tap.subscribe(onNext: {
                    self.menuSelectedRelay.accept(ToolData(type: .ink, value: menu))
                }).disposed(by: disposeBag)
            }
            stack.addArrangedSubview(btn)
            btn.snp.makeConstraints {
                $0.height.equalTo(30)
            }
            index += 1
        }
    }
    
    lazy var penBtn = UIButton().then {
        $0.setImage(UIImage(named: "pen")?
            .withTintColor(menuColor), for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        $0.layer.cornerRadius = 15
        $0.backgroundColor = #colorLiteral(red: 0.8983803391, green: 0.9096899629, blue: 0.9094910026, alpha: 1)
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.isDrawingMode = true
            self.changeDrawingMode()
            self.changeDrawingBtnBackground()
        }).disposed(by: disposeBag)
    }
    
    lazy var eraserBtn = UIButton().then {
        $0.setImage(UIImage(named: "eraser")?
            .withTintColor(menuColor), for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        $0.layer.cornerRadius = 15
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.isDrawingMode = false
            self.changeDrawingMode()
            self.changeDrawingBtnBackground()
        }).disposed(by: disposeBag)
    }
    
    lazy var shareBtn = UIButton().then {
        $0.setImage(UIImage(named: "share")?
            .withTintColor(menuColor), for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.share()
        }).disposed(by: disposeBag)
    }
    
    lazy var downloadBtn = UIButton().then {
        $0.setImage(UIImage(named: "download")?
            .withTintColor(menuColor), for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
        }).disposed(by: disposeBag)
    }
    
    lazy var colorStack = UIStackView().then {
        $0.spacing = 5
        $0.backgroundColor = .white
        
        var tag = 0
        for color in colorArr {
            let colorBtn = UIButton().then { btn in
                btn.backgroundColor = #colorLiteral(red: 0.9464568496, green: 0.9583716989, blue: 0.9581621289, alpha: 1)
                btn.layer.cornerRadius = 20
                btn.tag = tag
                btn.rx.tap.subscribe(onNext: { [weak self] in
                    guard let `self` = self else { return }
                    self.changeColor(tag: btn.tag, btn: btn)
                }).disposed(by: disposeBag)
            }
            
            let colorView = UIView().then {
                $0.backgroundColor = color
                $0.layer.cornerRadius = 15
                $0.isUserInteractionEnabled = false
            }
            
            $0.addArrangedSubview(colorBtn)
            colorBtn.addSubview(colorView)
            
            colorBtn.snp.makeConstraints {
                $0.size.equalTo(40)
            }
            
            colorView.snp.makeConstraints {
                $0.size.equalTo(30)
                $0.center.equalToSuperview()
            }
            
            if tag == 0 {
                self.currentBtn = colorBtn
            }
            tag += 1
        }
        $0.addArrangedSubview(UIView())
    }
    
    lazy var toastView = UIView().then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 8
        $0.isHidden = true
        $0.alpha = 0
        $0.isUserInteractionEnabled = false
    }
    
    private func setupLayout() {
        let spacingView = UIView()
        
        addSubview(canvasView)
        addSubview(toolBtn)
        addSubview(toolView)
        addSubview(sizeSelectView)
        addSubview(penSelectView)
        addSubview(doBtnStack)
        
        doBtnStack.addArrangedSubview(undoBtn)
        doBtnStack.addArrangedSubview(redoBtn)
        
        toolView.addSubview(toolStack)
        toolView.addSubview(colorStack)
        
        toolStack.addArrangedSubview(sizeBtn)
        toolStack.addArrangedSubview(penTypeBtn)
        toolStack.addArrangedSubview(penBtn)
        toolStack.addArrangedSubview(eraserBtn)
        toolStack.addArrangedSubview(spacingView)
        toolStack.addArrangedSubview(downloadBtn)
        toolStack.addArrangedSubview(shareBtn)
        toolStack.addArrangedSubview(UIView())
        
        canvasView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        doBtnStack.snp.makeConstraints {
            $0.top.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        undoBtn.snp.makeConstraints {
            $0.size.equalTo(40)
        }
        
        redoBtn.snp.makeConstraints {
            $0.size.equalTo(40)
        }
        
        toolBtn.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 70, height: 30))
            $0.bottom.equalTo(toolView.snp.top)
            $0.centerX.equalTo(toolView)
        }
        
        toolView.snp.makeConstraints {
            $0.leading.right.equalToSuperview()
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        toolStack.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        sizeBtn.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 60, height: 30))
        }
        
        sizeSelectView.snp.makeConstraints {
            $0.leading.width.equalTo(sizeBtn)
            $0.bottom.equalTo(sizeBtn.snp.top)
        }
        
        penTypeBtn.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 60, height: 30))
        }
        
        penSelectView.snp.makeConstraints {
            $0.leading.width.equalTo(penTypeBtn)
            $0.bottom.equalTo(penTypeBtn.snp.top)
        }
        
        penBtn.snp.makeConstraints {
            $0.size.equalTo(30)
        }
        
        eraserBtn.snp.makeConstraints {
            $0.size.equalTo(30)
        }
        
        spacingView.snp.makeConstraints {
            $0.width.equalTo(20)
        }
        
        downloadBtn.snp.makeConstraints {
            $0.size.equalTo(30)
        }
        
        shareBtn.snp.makeConstraints {
            $0.size.equalTo(30)
        }
        
        colorStack.snp.makeConstraints {
            $0.top.equalTo(toolStack.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(40)
        }
    }
}

struct ToolData {
    let type: ToolType
    let value: Any
}

enum ToolType {
    case ink
    case color
    case width
}
