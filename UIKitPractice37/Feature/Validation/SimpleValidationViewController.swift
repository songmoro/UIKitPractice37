//
//  SimpleValidationViewController.swift
//  UIKitPractice37
//
//  Created by 송재훈 on 8/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SimpleValidationViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private var usernameTextField = UITextField()
    private var usernameValidLabel = UILabel()

    private var passwordTextField = UITextField()
    private var passwordValidLabel = UILabel()

    private var signInButton = UIButton(configuration: .filled())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind()
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        
        view.addSubviews {
            usernameTextField
            usernameValidLabel
            passwordTextField
            passwordValidLabel
            signInButton
        }
        
        usernameTextField.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview(\.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(40)
        }
        
        usernameValidLabel.snp.makeConstraints {
            $0.top.equalTo(usernameTextField.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview(\.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(20)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(usernameValidLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview(\.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(40)
        }
        
        passwordValidLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview(\.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(20)
        }
        
        signInButton.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview(\.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(40)
        }
        
        usernameTextField.borderStyle = .bezel
        passwordTextField.borderStyle = .bezel
        signInButton.isEnabled = false
        signInButton.configuration?.title = "완료 및 뒤로 가기"
    }
    
    private func bind() {
        let isUsernameTextFieldValid = usernameTextField.rx.text
            .map { $0 != nil && $0!.count >= 4 }
            .share()
        
        let isPasswordTextFieldValid = passwordTextField.rx.text
            .map { $0 != nil && $0!.count >= 5 }
            .share()
        
        let isAvailableAccount = Observable.combineLatest(isUsernameTextFieldValid, isPasswordTextFieldValid)
            .map { $0 && $1 }
            .share()
        
        disposeBag.insert {
            isUsernameTextFieldValid
                .map { $0 ? "올바른 입력입니다." : "닉네임은 최소 4글자입니다." }
                .bind(to: usernameValidLabel.rx.text)
            
            isUsernameTextFieldValid
                .map { $0 ? UIColor.systemGreen : UIColor.systemRed }
                .bind(to: usernameValidLabel.rx.textColor)
            
            isPasswordTextFieldValid
                .map { $0 ? "올바른 입력입니다." : "비밀번호는 최소 5글자입니다." }
                .bind(to: passwordValidLabel.rx.text)
            
            isPasswordTextFieldValid
                .map { $0 ? UIColor.systemGreen : UIColor.systemRed }
                .bind(to: passwordValidLabel.rx.textColor)
            
            isAvailableAccount
                .bind(to: signInButton.rx.isEnabled)
            
            signInButton.rx.tap
                .bind(with: self) {
                    _ = $1
                    $0.navigationController?.popViewController(animated: true)
                }
        }
    }
}
