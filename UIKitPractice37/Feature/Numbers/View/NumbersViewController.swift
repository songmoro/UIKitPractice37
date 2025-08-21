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
