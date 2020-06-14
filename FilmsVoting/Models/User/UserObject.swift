//
//  UserObject.swift
//  FilmsVoting
//
//  Created by Владислав on 14.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit
import CoreData

@objc(UserObject)
class UserObject: NSManagedObject {
    
    @NSManaged public var password: String
    @NSManaged public var name: String
    @NSManaged public var id: UUID
    @NSManaged public var login: String

        
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserObject> {
        return NSFetchRequest<UserObject>(entityName: "UserObject");
    }
    

}

extension UserObject{
    func toUser() -> User {
        return User(id: self.id, password: self.password, name: self.name, login: self.login)
    }
}
