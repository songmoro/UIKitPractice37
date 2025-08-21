//
//  HomeworkViewModel.swift
//  UIKitPractice37
//
//  Created by 송재훈 on 8/21/25.
//

import RxSwift
import RxCocoa

final class HomeworkViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let searchButtonClicked: ControlEvent<Void>
        let searchText: ControlProperty<String>
        let modelSelected: ControlEvent<Person>
    }
    
    struct Output {
        let tableViewData: Driver<[Person]>
        let collectionViewData: Driver<[Person]>
    }
    
    func transform(_ input: Input) -> Output {
        let tableViewData = BehaviorRelay<[Person]>(value: Person.list)
        let collectionViewData = BehaviorRelay<[Person]>(value: [])
        let appendTableViewData = PublishRelay<Person>()
        
        disposeBag.insert {
            input.searchButtonClicked
                .withLatestFrom(input.searchText)
                .distinctUntilChanged()
                .map { Person(name: $0, email: "", profileImage: Person.list[0].profileImage) }
                .bind(to: appendTableViewData)
            
            appendTableViewData
                .withLatestFrom(tableViewData) { $1 + [$0] }
                .bind(to: tableViewData)
            
            input.modelSelected
                .withLatestFrom(collectionViewData) { $1 + [$0] }
                .bind(to: collectionViewData)
        }
        
        return .init(
            tableViewData: tableViewData.asDriver(),
            collectionViewData: collectionViewData.asDriver()
        )
    }
}
