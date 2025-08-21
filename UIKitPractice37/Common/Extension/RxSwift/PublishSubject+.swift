//
//  PublishSubject+.swift
//  UIKitPractice37
//
//  Created by 송재훈 on 8/20/25.
//

import RxSwift

extension PublishSubject {
    func appendTo(_ subject: BehaviorSubject<[Element]>) -> any Disposable {
        self.withUnretained(subject)
            .compactMap(appendElement)
            .bind(to: subject)
    }
    
    private func appendElement(_ tuple: (BehaviorSubject<[Element]>, Element)) throws -> [Element] {
        try tuple.0.value() + [tuple.1]
    }
}

//import RxSwift
//import RxCocoa
//
//extension PublishRelay {
//    func appendTo(_ subject: BehaviorRelay<[Element]>) -> any Disposable {
//        self.withUnretained(subject)
//            .compactMap(appendElement)
//            .bind(to: subject)
//    }
//    
//    private func appendElement(_ tuple: (BehaviorRelay<[Element]>, Element)) throws -> [Element] {
//        tuple.0.value + [tuple.1]
//    }
//}
