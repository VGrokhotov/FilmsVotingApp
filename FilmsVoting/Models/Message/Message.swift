//
//  Message.swift
//  FilmsVoting
//
//  Created by Владислав on 22.07.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import Foundation

struct Message: Codable {
    let type: MessageType
    let content: Data?
}

enum MessageType: String, Codable {
    case room = "room"
    case option = "option"
    case connectRoom = "connectRoom"
    case connectOption = "connectOption"
    case disconnect = "disconnect"
    case disconnectFromOption = "disconnectFromOption"
    case startVoting = "startVoting"
    case endVoting = "endVoting"
    case exit = "exit"
}
