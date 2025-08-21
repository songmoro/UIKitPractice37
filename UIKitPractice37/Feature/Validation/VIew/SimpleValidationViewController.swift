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
    deinit {
        print(self, "deinit")
    }
    
    private let disposeBag = DisposeBag()
    
    private let viewModel = SimpleValidationViewModel()
    
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
        
        [usernameTextField, passwordTextField].forEach { $0.borderStyle = .bezel }
        signInButton.isEnabled = false
        signInButton.configuration?.title = "완료 및 뒤로 가기"
    }
    
    private func bind() {
        let output = viewModel.transform(
            .init(
                username: usernameTextField.rx.text.orEmpty,
                password: passwordTextField.rx.text.orEmpty
            )
        )
        
        disposeBag.insert {
            output.validUsername
                .map { $0 ? "올바른 입력입니다." : "닉네임은 최소 4글자입니다." }
                .bind(to: usernameValidLabel.rx.text)
            
            output.validUsername
                .map { $0 ? UIColor.systemGreen : UIColor.systemRed }
                .bind(to: usernameValidLabel.rx.textColor)
            
            output.validPassword
                .map { $0 ? "올바른 입력입니다." : "비밀번호는 최소 5글자입니다." }
                .bind(to: passwordValidLabel.rx.text)
            
            output.validPassword
                .map { $0 ? UIColor.systemGreen : UIColor.systemRed }
                .bind(to: passwordValidLabel.rx.textColor)
            
            output.availableAccount
                .bind(to: signInButton.rx.isEnabled)
            
            signInButton.rx.tap
                .bind(withIgnoreOutput: self) {
                    $0.navigationController?.popViewController(animated: true)
                }
        }
    }
}
