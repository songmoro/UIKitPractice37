//
//  HomeworkViewController.swift
//  RxSwift
//
//  Created by Jack on 1/30/25.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

final class HomeworkViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let disposeBag2 = DisposeBag()
    
    private let sampleUsers = BehaviorSubject<[Person]>(value: Person.list)
    private let usersSubject = BehaviorSubject<[Person]>(value: [])
    
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
            let transitionSubject = PublishSubject<Void>()
            let transformSubject = PublishSubject<Person>()
            let transformSubject2 = PublishSubject<Person>()
            
            sampleUsers
//                .observe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
//                .map { (person: [Person]) throws -> [(name: String, image: UIImage)] in
//                    let newPerson = person.compactMap { p -> (name: String, image: UIImage)? in
//                        let name = p.name
//                        let url = URL(string: p.profileImage)
//                        
//                        if let url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
//                            return (name, image)
//                        }
//                        
//                        return nil
//                    }
//                    
//                    return newPerson
//                }
//                .observe(on: MainScheduler.instance)
                .bind(to: tableView.rx.items(cellIdentifier: PersonTableViewCell.identifier, cellType: PersonTableViewCell.self)) {
                    _ = ($0)
                    $2.usernameLabel.text = $1.name
                    $2.detailButton.rx.tap.bind(to: transitionSubject).disposed(by: $2.disposeBag)
                    
                    if let url = URL(string: $1.profileImage) {
                        $2.profileImageView.kf.indicatorType = .activity
                        $2.profileImageView.kf.setImage(with: url)
                    }
                }
            
            tableView.rx.modelSelected(Person.self)
                .bind(to: transformSubject)
            
            transformSubject
                .withUnretained(usersSubject)
                .compactMap(appendElement)
                .bind(to: usersSubject)
            
            transformSubject2
                .withUnretained(sampleUsers)
                .compactMap(appendElement)
                .bind(to: sampleUsers)
            
            usersSubject
                .bind(to: collectionView.rx.items(cellIdentifier: UserCollectionViewCell.identifier, cellType: UserCollectionViewCell.self)) {
                    $2.label.text = $1.name
                }
            
            searchBar.rx.searchButtonClicked
                .withLatestFrom(searchBar.rx.text.orEmpty)
                .map { Person(name: $0, email: "", profileImage: Person.list[0].profileImage) }
                .bind(to: transformSubject2)
            
            
            transitionSubject
                .bind(withIgnoreOutput: self) {
                    let vc = SecondViewController()
                    $0.navigationController?.pushViewController(vc, animated: true)
                }
        }
    }
    
    private func appendElement<T>(tuple: (BehaviorSubject<[T]>, T)) throws -> [T] {
        try tuple.0.value() + [tuple.1]
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
