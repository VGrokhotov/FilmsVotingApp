//
//  NewRoomViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 19.04.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class NewRoomViewController: UIViewController {
    
    private var isKeyboardShown = false
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var maxMembersTextField: UITextField!
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBAction func createButtonPressed() {
        activityIndicator.startAnimating()
        
        disable(views: nameTextField, passwordTextField, maxMembersTextField, createButton)

        guard
            let password = passwordTextField.text,
            let name = nameTextField.text,
            let maxMembersStr = maxMembersTextField.text,
            let _ = Int(maxMembersStr)
        else { return }
        
        //fix creator id
        let newRoom = Room(id: nil, password: password, name: name, creatorID: UserAuthorization.shared.user!.id!)
        
        RoomsService.shared.create(room: newRoom, errorCompletion: { [ weak self] (message) in
            self?.activityIndicator.stopAnimating()
            self?.badURLAlert(message: message)
        }) { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.successAlert()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurate(button: createButton)
        
        registerForKeyboardNotification()
        
        setupToHideKeyboardOnTapOnView()
        
        nameTextField.delegate = self
        passwordTextField.delegate = self
        maxMembersTextField.delegate = self
        
        addTargetTo(textField: nameTextField)
        addTargetTo(textField: passwordTextField)
        addTargetTo(textField: maxMembersTextField)
    }
    
    deinit {
        removeKeyboardNotification()
    }
    
    func addTargetTo(textField: UITextField) {
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    // MARK: Alerts

    func badURLAlert(message: String){
        
        activate(views: nameTextField, passwordTextField, maxMembersTextField, createButton)
        
        let allert = UIAlertController(title: "Error occurred", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
    
    func successAlert(){
        
        let allert = UIAlertController(title: "Success", message: "New room created successfully!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
}



// MARK: - Text field delegate

extension NewRoomViewController: UITextFieldDelegate{
    
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
        return nameTextField.text?.isEmpty ?? true || passwordTextField.text?.isEmpty ?? true || maxMembersTextField.text?.isEmpty ?? true
    }
    
}


//MARK: Show the content above the keyboard

extension NewRoomViewController{
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if maxMembersTextField.isEditing {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//
//            if self.view.frame.origin.y == 0 {
//                self.view.frame.origin.y -= keyboardSize.height
//            }
//
//            }}
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if maxMembersTextField.isEditing {
//        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
//            }}
//    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        createButton.isHidden = true
        if !isKeyboardShown{
            isKeyboardShown = true
            if maxMembersTextField.isEditing {
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
