//
//  MainViewController.swift
//  UIKitPractice37
//
//  Created by 송재훈 on 8/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MainViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let items = [NumbersViewController.self, SimpleValidationViewController.self, HomeworkViewController.self]
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind()
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        disposeBag.insert {
            Observable.just(items)
                .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (_, vc, cell) in
                    cell.textLabel?.text = String(describing: vc)
                    cell.accessoryType = .detailButton
                }
            
            tableView.rx.modelSelected(UIViewController.Type.self)
                .map { $0.init() }
                .bind(with: self) {
                    $0.navigationController?.pushViewController($1, animated: true)
                }
            
            Observable.combineLatest(Observable.just(items), tableView.rx.itemAccessoryButtonTapped)
                .map { $0[$1.row] }
                .bind(with: self) {
                    let alert = UIAlertController(title: "해당 화면은", message: String(describing: $1), preferredStyle: .alert)
                    alert.addAction(.init(title: "확인", style: .default))
                    $0.present(alert, animated: true)
                }
        }
    }
}
