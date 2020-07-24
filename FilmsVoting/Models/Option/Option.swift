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

struct OptionWithSelection: Codable {
    let id: UUID?
    let content: String
    let roomID: UUID
    let vote: Int
    var selected: Bool
}

extension Option {
    func toOptionWithSelection() -> OptionWithSelection {
        return OptionWithSelection(id: id, content: content, roomID: roomID, vote: vote, selected: false)
    }
}

extension OptionWithSelection {
    func toOption() -> Option {
        return Option(id: id, content: content, roomID: roomID, vote: vote)
    }
}

struct OptionID: Codable {
    let id: UUID
}
