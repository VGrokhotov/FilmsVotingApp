//
//  RoomViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 21.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController {
    
    var room: Room?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = room?.name
    }
    
    static func makeVC(with room: Room ) -> RoomViewController {
        
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: RoomViewController.self)) as? RoomViewController
        
        guard let newVC = newViewController else {return RoomViewController()}
        
        newVC.room = room

        return newVC
    }
    

}
