//
//  Person.swift
//  UIKitPractice37
//
//  Created by 송재훈 on 8/20/25.
//

import Foundation

struct Person: Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let profileImage: String
}
