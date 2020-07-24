//
//  Room.swift
//  FilmsVoting
//
//  Created by Владислав on 24.04.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import Foundation

struct Room: Codable {
    let id: UUID?
    let password: String
    let name: String
    let creatorID: UUID
}

struct NotVerifiedRoom: Codable {
    let id: UUID?
    let name: String
}

struct AuthorizationRoom: Codable {
    let id: UUID?
    let password: String
}

struct RoomID: Codable {
    let id: UUID
}
