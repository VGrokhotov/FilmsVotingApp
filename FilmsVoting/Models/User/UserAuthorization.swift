//
//  UserAuthorization.swift
//  FilmsVoting
//
//  Created by Владислав on 14.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import Foundation

class UserAuthorization {
    
    let usersStorageManager: UsersDataManager = UsersStorageManager()
    var user: User?
    
    var isAuthorized: Bool {
        if let currentUser = usersStorageManager.getUser() {
            user = currentUser
            return true
        }
        user = nil
        return false
    }
    
    public static let shared = UserAuthorization() // создаем Синглтон
    private init(){}
    
}
