//
//  NewUserViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 18.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class NewUserViewController: UIViewController {
    
    private var isKeyboardShown = false
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func createButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        
        disable(views: nameTextField, passwordTextField, loginTextField, createButton)

        guard
            let password = passwordTextField.text,
            let name = nameTextField.text,
            let login = loginTextField.text
        else { return }
        
        let newUser = User(id: nil, password: password, name: name, login: login)
        
        UsersService.shared.create(user: newUser, errorCompletion: { [ weak self] (message) in
            self?.activityIndicator.stopAnimating()
            self?.badURLAlert(message: message)
        }) { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.successAlert()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeAlert()
        
        configurate(button: createButton)
        
        registerForKeyboardNotification()
        
        setupToHideKeyboardOnTapOnView()
        
        nameTextField.delegate = self
        passwordTextField.delegate = self
        loginTextField.delegate = self
        
        addTargetTo(textField: nameTextField)
        addTargetTo(textField: passwordTextField)
        addTargetTo(textField: loginTextField)
    }
    
    deinit {
        removeKeyboardNotification()
    }
    
    
    func disable(views: UIControl...) {
        for view in views {
            view.isEnabled = false
        }
    }
    
    func activate(views: UIControl...) {
        for view in views {
            view.isEnabled = true
        }
    }
    
    func configurate(button: UIButton) {
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2.0
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        button.clipsToBounds = true
    }
    
    func addTargetTo(textField: UITextField) {
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    func hide(view: UIView) {
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = 0
        }) { (finished) in
            view.isHidden = finished
        }
    }
    
    func show(view: UIView) {
        view.alpha = 0
        view.isHidden = false
        UIView.animate(withDuration: 0.6) {
            view.alpha = 1
        }
    }
    
    //MARK: Alerts
    
    func welcomeAlert(){
        
        let allert = UIAlertController(title: "Sign in", message: "To sign in you should create a new profile", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
    
    func badURLAlert(message: String){
        
        activate(views: nameTextField, passwordTextField, loginTextField, createButton)
        
        let allert = UIAlertController(title: "Error occurred", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
    
    func successAlert(){
        
        let allert = UIAlertController(title: "Success", message: "Your profile created successfully!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
    

}

extension NewUserViewController: UITextFieldDelegate{
    
    //To close the keyboard after Done pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        
        if areFieldsEmpty()  {
            hide(view: createButton)
        }
    }
    
    func areFieldsEmpty() -> Bool {
        return nameTextField.text?.isEmpty ?? true || passwordTextField.text?.isEmpty ?? true || loginTextField.text?.isEmpty ?? true
    }
    
}

//MARK: Show the content above the keyboard

extension NewUserViewController{
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        createButton.isHidden = true
        if !isKeyboardShown{
            isKeyboardShown = true
            if nameTextField.isEditing {
                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    
                    if self.view.frame.origin.y == 0 {
                        self.view.frame.origin.y -= keyboardSize.height
                    }
                    
                }
                
            }
            
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if !areFieldsEmpty() {
            show(view: createButton)
        }
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
        isKeyboardShown = false
        
    }
}
