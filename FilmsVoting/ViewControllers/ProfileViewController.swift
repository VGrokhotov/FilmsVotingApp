//
//  ProfileViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 17.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginField: UILabel!
    
    @IBAction func logInButtonPressed(_ sender: Any) {
    }
    @IBAction func signInButtonPressed(_ sender: Any) {
    }
    @IBAction func logOutButtonPressed(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurate(buttons: logInButton, logOutButton, signInButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserAuthorization.shared.isAuthorized {
            authorized()
        } else {
            notAuthorized()
        }
    }
    
    func configurate(buttons: UIButton...) {
        for button in buttons {
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 2.0
            button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            button.clipsToBounds = true
        }
    }
    
    func authorized() {
        loginField.text = UserAuthorization.shared.user?.login
        nameField.text = UserAuthorization.shared.user?.name
        show(views: logOutButton, loginField, loginLabel, nameField, nameLabel)
        hide(views: logInButton, signInButton)
    }
    
    func notAuthorized() {
        loginField.text = ""
        nameField.text = ""
        hide(views: logOutButton, loginField, loginLabel, nameField, nameLabel)
        show(views: logInButton, signInButton)
    }
    
    func hide(views: UIView...) {
        for view in views {
            view.isHidden = true
        }
    }
    
    func show(views: UIView...) {
        for view in views {
            view.isHidden = false
        }
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
