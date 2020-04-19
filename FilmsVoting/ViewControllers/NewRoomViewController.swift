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
    private var isKeyboardShown = false
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var maxMembersTextField: UITextField!
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBAction func createButtonPressed() {
        activityIndicator.startAnimating()
        
        disable(views: nameTextField, passwordTextField, maxMembersTextField, createButton)

        //send Post /rooms with completion
//        let completion = {
//            self.dismiss(animated: true, completion: self.comletion)
//        }
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
    
    
    func disable(views: UIControl...) {
        for view in views {
            view.isEnabled = false
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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

//MARK: To dismiss keyboard after tapping anywhere else

extension UIViewController
{
    func setupToHideKeyboardOnTapOnView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
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
    
        if maxMembersTextField.isEditing && !isKeyboardShown{
            isKeyboardShown = true
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
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