//
//  LogInViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 18.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logInButton: UIButton!
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        
        disable(views: passwordTextField, loginTextField, logInButton)

        guard
            let password = passwordTextField.text,
            let login = loginTextField.text
        else { return }
        
        UsersService.shared.getUserByLoginWithPassword(
            login: login,
            password: password,
            errorCompletion: { [ weak self] (message) in
                self?.activityIndicator.stopAnimating()
                self?.badResponseAlert(message: message)
            }) { [weak self] (user) in
                UsersStorageManager.shared.saveUser(user: user) {
                    self?.activityIndicator.stopAnimating()
                    self?.successAlert()
                }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurate(button: logInButton)
        
        setupToHideKeyboardOnTapOnView()
        
        passwordTextField.delegate = self
        loginTextField.delegate = self
        
        addTargetTo(textField: passwordTextField)
        addTargetTo(textField: loginTextField)
    }
    
    func addTargetTo(textField: UITextField) {
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    //MARK: Alerts
    
    func badResponseAlert(message: String){
        
        activate(views: passwordTextField, loginTextField, logInButton)
        
        let allert = UIAlertController(title: "Error occurred", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
    
    func successAlert(){
        
        let allert = UIAlertController(title: "Success", message: "You logged in successfully!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
}

extension LogInViewController: UITextFieldDelegate{
    
    //To close the keyboard after Done pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        
        if areFieldsEmpty()  {
            hide(view: logInButton)
        } else {
            show(view: logInButton)
        }
    }
    
    func areFieldsEmpty() -> Bool {
        return passwordTextField.text?.isEmpty ?? true || loginTextField.text?.isEmpty ?? true
    }
    
}
