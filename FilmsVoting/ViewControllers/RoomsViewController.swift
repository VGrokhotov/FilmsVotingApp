//
//  ViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 19.04.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class RoomsViewController: UIViewController {
    
    var authorized = true
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newRoomButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !authorized {
            isNotAuthorized()
        }
    }
    
    func isNotAuthorized(){
        tableView.isHidden = true
        newRoomButton.isEnabled = false
        authorizationAlert()
    }
    
    //MARK: Alert
    
    func authorizationAlert(){
        
        let allert = UIAlertController(title: "You are not authorized", message: "To see rooms, please, authorize", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
    
    //MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewRoom" {
            let newRoom = segue.destination as? NewRoomViewController
            
            newRoom?.comletion = {
                //мб вообще не нужно если поставить вебсокет на комнаты
                //сделать Get /rooms
                self.tableView.reloadData()
            }
        }
    }

}

