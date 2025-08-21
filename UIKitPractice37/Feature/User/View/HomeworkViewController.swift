//
//  HomeworkViewController.swift
//  RxSwift
//
//  Created by Jack on 1/30/25.
//

import UIKit
import SnapKit
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

final class HomeworkViewController: UIViewController {
    deinit {
        print(self, "deinit")
    }
    
    private let disposeBag = DisposeBag()
    
    private let viewModel = HomeworkViewModel()
    
    private let tableView = UITableView()
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let searchBar = UISearchBar()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind()
    }
     
    private func bind() {
        let output = viewModel.transform(
            .init(
                searchButtonClicked: searchBar.rx.searchButtonClicked,
                searchText: searchBar.rx.text.orEmpty,
                modelSelected: tableView.rx.modelSelected(Person.self)
            )
        )
        
        let transition = PublishRelay<Person>()
        
        disposeBag.insert {
            output.tableViewData
                .drive(tableView.rx.items(cellIdentifier: PersonTableViewCell.identifier, cellType: PersonTableViewCell.self)) {
                    $2.modelSubject.onNext($1)
                    $2.buttonSubject.bind(to: transition).disposed(by: $2.disposeBag)
                }
            
            output.collectionViewData
                .drive(collectionView.rx.items(cellIdentifier: UserCollectionViewCell.identifier, cellType: UserCollectionViewCell.self)) {
                    $2.label.text = $1.name
                }
            
            transition
                .bind(with: self) {
                    let vc = SecondViewController()
                    vc.navigationItem.title = $1.name
                    vc.label.text = $1.name
                    $0.navigationController?.pushViewController(vc, animated: true)
                }
        }
    }
    
    private func configure() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        
        navigationItem.titleView = searchBar
         
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: UserCollectionViewCell.identifier)
        collectionView.backgroundColor = .lightGray
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: PersonTableViewCell.identifier)
        tableView.backgroundColor = .systemGreen
        tableView.rowHeight = 100
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        collectionView.collectionViewLayout = layout()
    }
    
    private func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 40)
        layout.scrollDirection = .horizontal
        return layout
    }
}
