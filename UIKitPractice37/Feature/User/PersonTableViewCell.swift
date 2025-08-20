//
//  UserTableViewCell.swift
//  iOSAcademy-RxSwift
//
//  Created by Jack on 1/30/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

final class PersonTableViewCell: UITableViewCell {
    static let identifier = "PersonTableViewCell"
    
    deinit {
        print(self, "deinit")
    }
    
    var disposeBag = DisposeBag()
    
    var modelSubject = BehaviorSubject<Person?>(value: nil)
    var buttonSubject = PublishSubject<Person>()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemMint
        imageView.layer.cornerRadius = 8
        imageView.kf.indicatorType = .activity
        return imageView
    }()
    let detailButton: UIButton = {
        let button = UIButton()
        button.setTitle("더보기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.isUserInteractionEnabled = true
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 16
        return button
    }()
      
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        configure()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    private func configure() {
        contentView.addSubview(usernameLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(detailButton)
        
        profileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(20)
            $0.size.equalTo(60)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.trailing.equalTo(detailButton.snp.leading).offset(-8)
        }
        
        detailButton.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(32)
            $0.width.equalTo(72)
        }
    }
    
    private func bind() {
        let usernameLabelSubject = PublishSubject<Person>()
        let profileImageViewSubject = PublishSubject<Person>()
        
        disposeBag.insert {
            modelSubject
                .compactMap(\.self)
                .bind(to: usernameLabelSubject, profileImageViewSubject)
            
            usernameLabelSubject
                .map(\.name)
                .bind(to: usernameLabel.rx.text)
            
            profileImageViewSubject
                .map(\.profileImage)
                .compactMap(URL.init(string:))
                .bind(with: self) {
                    $0.profileImageView.kf.setImage(with: $1)
                }
            
            detailButton.rx.tap
                .withLatestFrom(modelSubject)
                .compactMap(\.self)
                .bind(to: buttonSubject)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        bind()
    }
}
