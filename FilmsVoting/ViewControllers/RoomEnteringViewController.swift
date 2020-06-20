//
//  RoomEnteringViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 21.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class RoomEnteringViewController: UIViewController {
    
    var notVerifiedRoom: NotVerifiedRoom?

    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var roomPasswordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var enterButton: UIButton!
    
    @IBAction func enterButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        
        disable(views: roomPasswordTextField, enterButton)

        guard
            let password = roomPasswordTextField.text,
            let id = notVerifiedRoom?.id
        else { return }
        
        RoomsService.shared.getRoomByIDWithPassword(
            id: id,
            password: password,
            errorCompletion: { [ weak self] (message) in
                self?.activityIndicator.stopAnimating()
                self?.badResponseAlert(message: message)
        }) { [weak self] (room) in
            self?.activityIndicator.stopAnimating()
            self?.successAlert(room)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurate(button: enterButton)
        
        setupToHideKeyboardOnTapOnView()
        
        roomPasswordTextField.delegate = self
        
        addTargetTo(textField: roomPasswordTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "Enter the Room"
        roomNameLabel.text = notVerifiedRoom?.name
    }
    
    static func makeVC(with notVerifiedRoom: NotVerifiedRoom ) -> RoomEnteringViewController {
        
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: RoomEnteringViewController.self)) as? RoomEnteringViewController
        
        guard let newVC = newViewController else {return RoomEnteringViewController()}
        
        newVC.notVerifiedRoom = notVerifiedRoom

        return newVC
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
    
    func configurate(button: UIButton) {
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2.0
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        button.clipsToBounds = true
    }
    
    func addTargetTo(textField: UITextField) {
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    //MARK: Alerts
    
    func badResponseAlert(message: String){
        
        activate(views: roomPasswordTextField, enterButton)
        
        let allert = UIAlertController(title: "Error occurred", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
    
    func successAlert(_ room: Room){
        
        let allert = UIAlertController(title: "Success", message: "You entered the Room \(notVerifiedRoom!.name) successfully!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            //переход дальше c передачей дальше комнаты
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
    

}


extension RoomEnteringViewController: UITextFieldDelegate{
    
    //To close the keyboard after Done pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        
        if areFieldsEmpty()  {
            hide(view: enterButton)
        } else {
            show(view: enterButton)
        }
    }
    
    func areFieldsEmpty() -> Bool {
        return roomPasswordTextField.text?.isEmpty ?? true
    }
    
}
