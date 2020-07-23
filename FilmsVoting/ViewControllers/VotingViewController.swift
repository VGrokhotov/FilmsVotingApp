//
//  VotingViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 23.07.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class VotingViewController: UIViewController {
    
    private var options: [Option] = []
    private var isCreator: Bool = false
    private var roomID: UUID = UUID()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Voting"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isCreator {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "stop.fill"), style: .plain, target: self, action: #selector(endVoting(sender:)))
        }
        
        let barItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(returnToRootController(sender:)))
        navigationItem.setLeftBarButton(barItem, animated: true)
    }
    
    @objc func returnToRootController(sender: UIBarButtonItem) {
        SocketService.shared.disconnectFromOption()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func endVoting(sender: UIBarButtonItem) {
        //SocketService.shared.endVoting(with: roomID)
    }
    
    static func makeVC(with options: [Option], roomID: UUID, isCreator: Bool ) -> VotingViewController {
        
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: VotingViewController.self)) as? VotingViewController
        
        guard let newVC = newViewController else { return VotingViewController() }
        
        newVC.options = options
        newVC.isCreator = isCreator
        newVC.roomID = roomID

        return newVC
    }

}
