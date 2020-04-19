//
//  NewRoomViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 19.04.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class NewRoomViewController: UIViewController {
    
    var comletion = {}

    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurate(button: createButton)
        // Do any additional setup after loading the view.
    }
    
    func configurate(button: UIButton) {
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2.0
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        button.clipsToBounds = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
