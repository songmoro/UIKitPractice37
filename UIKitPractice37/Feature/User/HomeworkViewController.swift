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

final class HomeworkViewController: UIViewController {
    deinit {
        print(self, "deinit")
    }
    
    private let disposeBag = DisposeBag()
    
    private let tableView = UITableView()
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let searchBar = UISearchBar()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind()
    }
     
    private func bind() {
        disposeBag.insert {
            let transitionSubject = PublishSubject<Person>()
            let collectionViewAppendSubject = PublishSubject<Person>()
            let tableViewAppendSubject = PublishSubject<Person>()
            let sampleUsers = BehaviorSubject<[Person]>(value: Person.list)
            let usersSubject = BehaviorSubject<[Person]>(value: [])
            
            sampleUsers
                .bind(to: tableView.rx.items(cellIdentifier: PersonTableViewCell.identifier, cellType: PersonTableViewCell.self)) {
                    _ = $0
                    
                    $2.modelSubject.onNext($1)
                    $2.buttonSubject.bind(to: transitionSubject).disposed(by: $2.disposeBag)
                }
            
            tableView.rx.modelSelected(Person.self)
                .bind(to: collectionViewAppendSubject)
            
            collectionViewAppendSubject
                .appendTo(usersSubject)
            
            tableViewAppendSubject
                .appendTo(sampleUsers)
            
            usersSubject
                .bind(to: collectionView.rx.items(cellIdentifier: UserCollectionViewCell.identifier, cellType: UserCollectionViewCell.self)) {
                    $2.label.text = $1.name
                }
            
            searchBar.rx.searchButtonClicked
                .withLatestFrom(searchBar.rx.text.orEmpty)
                .map { Person(name: $0, email: "", profileImage: Person.list[0].profileImage) }
                .bind(to: tableViewAppendSubject)
            
            transitionSubject
                .bind(with: self) {
                    let vc = SecondViewController()
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
