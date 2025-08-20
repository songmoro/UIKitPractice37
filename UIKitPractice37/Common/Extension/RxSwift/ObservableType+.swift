//
//  ObservableType+.swift
//  UIKitPractice37
//
//  Created by 송재훈 on 8/20/25.
//

import RxSwift

extension ObservableType {
    func bind<Object: AnyObject>(withIgnoreOutput object: Object, onNext: @escaping (Object) -> Void) -> Disposable {
        return self.bind(with: object) { owner, _ in
            onNext(owner)
        }
    }
}
