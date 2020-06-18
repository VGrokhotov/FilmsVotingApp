//
//  User.swift
//  FilmsVoting
//
//  Created by Владислав on 14.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: UUID?
    let password: String
    let name: String
    let login: String
}

struct NotVerifiedUser: Codable {
    let login: String
    let password: String
}
