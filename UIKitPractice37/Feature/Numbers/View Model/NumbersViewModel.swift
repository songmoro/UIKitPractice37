//
//  NumbersViewModel.swift
//  UIKitPractice37
//
//  Created by 송재훈 on 8/21/25.
//

import RxSwift
import RxCocoa

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
