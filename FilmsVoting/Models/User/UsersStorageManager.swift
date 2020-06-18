//
//  UsersStorageManager.swift
//  FilmsVoting
//
//  Created by Владислав on 14.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit
import CoreData

protocol UsersDataManager {
    
    func saveUser(user: User, completion: @escaping () -> ())
    
    func getUser() -> User?
    
    func deleteUser(completion: @escaping () -> ())
    
}

class UsersStorageManager: UsersDataManager {
    
    let fetchRequest = NSFetchRequest<UserObject>(entityName: "UserObject")
    
    private lazy var container: NSPersistentContainer = {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        if let appDelegate = appDelegate {
            return appDelegate.persistentContainer
        }
        
        return NSPersistentContainer()
    }()

    
    func saveUser(user: User, completion: @escaping () -> ()) {
        
        container.loadPersistentStores { (_, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
        }
        
        container.performBackgroundTask { (context) in
            
            guard let allUsers = try? context.fetch(self.fetchRequest) else { return }
            
            for userInContext in allUsers {
                context.delete(userInContext)
            }
            
            
            let currentUserObject = NSEntityDescription.insertNewObject(forEntityName: "UserObject", into: context) as? UserObject
            
            currentUserObject?.id = user.id
            currentUserObject?.login = user.login
            currentUserObject?.name = user.name
            currentUserObject?.password = user.password
            
            try? context.save()
            completion()
        }
    }
    
    func getUser() -> User? {
        
//        container.loadPersistentStores { (_, error) in
//            if let error = error {
//                assertionFailure(error.localizedDescription)
//            }
//        }
        
        guard let allUsers = try? container.viewContext.fetch(self.fetchRequest) else { return nil }
            
        return allUsers.first?.toUser()
    }
    
    func deleteUser(completion: @escaping () -> ()) {
        
        container.loadPersistentStores { (_, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
        }
        
        container.performBackgroundTask { (context) in
            
            guard let allUsers = try? context.fetch(self.fetchRequest) else { return }
            
            for userInContext in allUsers {
                context.delete(userInContext)
            }
            
            try? context.save()
            completion()
        }
    }
    
    
    
}