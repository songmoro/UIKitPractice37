//
//  SecondViewController.swift
//  UIKitPractice37
//
//  Created by 송재훈 on 8/20/25.
//

import UIKit
import SnapKit

final class SecondViewController: UIViewController {
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBrown
        
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.edges.equalToSuperview(\.safeAreaLayoutGuide)
        }
        
        
    }
}
