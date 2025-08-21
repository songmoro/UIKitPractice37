//
//  SimpleValidationViewModel.swift
//  UIKitPractice37
//
//  Created by 송재훈 on 8/21/25.
//

import RxSwift
import RxCocoa

final class SimpleValidationViewModel {
    deinit {
        print(self, "deinit")
    }
    
    struct Input {
        let username: ControlProperty<String>
        let password: ControlProperty<String>
    }
    struct Output {
        let validUsername: Observable<Bool>
        let validPassword: Observable<Bool>
        let availableAccount: Observable<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let isValidUsername = input.username
            .map { $0.count >= 4 }
            .share()
        
        let isValidPassword = input.password
            .map { $0.count >= 5 }
            .share()
        
        let isAvailableAccount = Observable.combineLatest(isValidUsername, isValidPassword)
            .map { $0 && $1 }
            .share()
        
        return .init(validUsername: isValidUsername, validPassword: isValidPassword, availableAccount: isAvailableAccount)
    }
}
