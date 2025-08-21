//
//  NumbersViewController.swift
//  UIKitPractice37
//
//  Created by 송재훈 on 8/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

//extension Reactive where Base: UITextField {
//    /// Reactive wrapper for `text` property.
//    public var text: ControlProperty<String?> {
//        value
//    }
//    
//    /// Reactive wrapper for `text` property.
//    public var value: ControlProperty<String?> {
//        return base.rx.controlPropertyWithDefaultEvents(
//            getter: { textField in
//                textField.text
//            },
//            setter: { textField, value in
//                // This check is important because setting text value always clears control state
//                // including marked text selection which is important for proper input
//                // when IME input method is used.
//                if textField.text != value {
//                    textField.text = value
//                }
//            }
//        )
//    }
//    
//    /// Bindable sink for `attributedText` property.
//    public var attributedText: ControlProperty<NSAttributedString?> {
//        return base.rx.controlPropertyWithDefaultEvents(
//            getter: { textField in
//                textField.attributedText
//            },
//            setter: { textField, value in
//                // This check is important because setting text value always clears control state
//                // including marked text selection which is important for proper input
//                // when IME input method is used.
//                if textField.attributedText != value {
//                    textField.attributedText = value
//                }
//            }
//        )
//    }
//}
//
//#endif


final class NumbersViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let firstText: ControlProperty<String>
        let secondText: ControlProperty<String>
        let thirdText: ControlProperty<String>
    }
    struct Output {
        let validFirst: PublishRelay<Bool>
        let validSecond: PublishRelay<Bool>
        let validThird: PublishRelay<Bool>
        let result: PublishRelay<String>
    }
    
    func transform(_ input: Input) -> Output {
        let first = input.firstText.map(Int.init).share()
        let second = input.secondText.map(Int.init).share()
        let third = input.thirdText.map(Int.init).share()
        
        let validFirst = PublishRelay<Bool>()
        let validSecond = PublishRelay<Bool>()
        let validThird = PublishRelay<Bool>()
        let result = PublishRelay<String>()
        
        disposeBag.insert {
            first
                .map { $0 != nil }
                .bind(to: validFirst)
            
            second
                .map { $0 != nil }
                .bind(to: validSecond)
            
            third
                .map { $0 != nil }
                .bind(to: validThird)
            
            Observable.combineLatest(first, second, third)
                .map(calculateTotal)
                .bind(to: result)
        }
        
        return .init(validFirst: validFirst, validSecond: validSecond, validThird: validThird, result: result)
    }
    
    private func calculateTotal(_ tuple: (Int?, Int?, Int?)) -> String {
        let total = (tuple.0 ?? 0) + (tuple.1 ?? 0) + (tuple.2 ?? 0)
        return total.description
    }
}

final class NumbersViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let viewModel = NumbersViewModel()
    
    private let textField1 = UITextField()
    private let textField2 = UITextField()
    private let textField3 = UITextField()
    
    private let resultLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind()
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        
        view.addSubviews {
            textField1
            textField2
            textField3
            resultLabel
        }
        
        textField1.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview(\.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(40)
        }
        
        textField2.snp.makeConstraints {
            $0.top.equalTo(textField1.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.height.equalTo(40)
        }
        
        textField3.snp.makeConstraints {
            $0.top.equalTo(textField2.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.height.equalTo(40)
        }
        
        resultLabel.snp.makeConstraints {
            $0.top.equalTo(textField3.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.height.equalTo(40)
        }
        
        [textField1, textField2, textField3].forEach {
            $0.layer.borderColor = UIColor.label.cgColor
            $0.layer.borderWidth = 1
        }
    }
    
    private func bind() {
        let output = viewModel.transform(
            .init(
                firstText: textField1.rx.text.orEmpty,
                secondText: textField2.rx.text.orEmpty,
                thirdText: textField3.rx.text.orEmpty
            )
        )
        
        disposeBag.insert {
            output.validFirst
                .map(extractCGColor)
                .bind(to: textField1.layer.rx.borderColor)
            
            output.validSecond
                .map(extractCGColor)
                .bind(to: textField2.layer.rx.borderColor)
            
            output.validThird
                .map(extractCGColor)
                .bind(to: textField3.layer.rx.borderColor)
            
            output.result
                .bind(to: resultLabel.rx.text)
        }
    }
    
    private func extractCGColor(_ isValid: Bool) -> CGColor {
        isValid ? UIColor.label.cgColor : UIColor.systemRed.cgColor
    }
}
