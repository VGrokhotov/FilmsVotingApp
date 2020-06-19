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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func logInButtonPressed(_ sender: Any) {
    }
    @IBAction func signInButtonPressed(_ sender: Any) {
    }
    @IBAction func logOutButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        UsersStorageManager.shared.deleteUser { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.logOutAlert()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurate(buttons: logInButton, logOutButton, signInButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkAuthorization()
    }
    
    func checkAuthorization() {
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
        hide(views: logOutButton, loginField, loginLabel, nameField, nameLabel)
        show(views: logInButton, signInButton)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loginField.text = ""
            self.nameField.text = ""
        }
    
    }
    
    func hide(views: UIView...) {
        for view in views {
            UIView.animate(withDuration: 0.5, animations: {
                view.alpha = 0
            }) { (finished) in
                view.isHidden = finished
            }
        }
    }
    
    func show(views: UIView...) {
        for view in views {
            view.alpha = 0
            view.isHidden = false
            UIView.animate(withDuration: 0.6) {
                view.alpha = 1
            }
        }
    }
    
    //MARK: Alerts
    
    func logOutAlert(){
        
        let allert = UIAlertController(title: "Success", message: "You logged out successfully!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.checkAuthorization()
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }

}
