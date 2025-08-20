//
//  SubviewBuilder.swift
//  UIKitPractice37
//
//  Created by 송재훈 on 8/19/25.
//

import UIKit

extension UIView {
    func addSubviews(subviews: UIView...) {
        subviews.forEach(addSubview)
    }
    
    func addSubviews(@SubviewBuilder builder: () -> [UIView]) {
        builder().forEach(addSubview)
    }
    
    @resultBuilder
    struct SubviewBuilder {
        public static func buildBlock(_ subviews: UIView...) -> [UIView] {
            return subviews
        }
    }
}
