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

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    static func makeVC(with options: [Option], isCreator: Bool ) -> VotingViewController {
        
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: VotingViewController.self)) as? VotingViewController
        
        guard let newVC = newViewController else { return VotingViewController() }
        
        newVC.options = options
        newVC.isCreator = isCreator

        return newVC
    }

}
