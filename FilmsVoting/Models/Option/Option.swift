//
//  Option.swift
//  FilmsVoting
//
//  Created by Владислав on 22.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

struct Option: Codable {
    let id: UUID?
    let content: String
    let roomID: UUID
    let vote: Int
}

struct OptionSelector: Codable {
    let roomID: UUID
}
