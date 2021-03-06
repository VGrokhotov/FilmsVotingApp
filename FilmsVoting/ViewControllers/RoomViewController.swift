//
//  RoomViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 21.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var optionTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addButton: UIButton!
    
    var room: Room?
    var options: [Option] = []
    
    @IBAction func addButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        
        disable(views: optionTextField, addButton)

        guard
            let content = optionTextField.text,
            let roomID = room?.id
        else { return }
        
        let newOption = Option(id: nil, content: content, roomID: roomID, vote: 0)
        
        OptionsService.shared.create(option: newOption, errorCompletion: { [ weak self] (message) in
            self?.activityIndicator.stopAnimating()
            self?.badCreatingURLAlert(message: message)
        }) { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.successAlert()
        }
        
        SocketService.shared.setExitCompletion { [weak self] in
            self?.exitAlert()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = room?.name
        
        disable(views: optionTextField, addButton)
        
        addButton.layer.cornerRadius = 10
        addButton.layer.borderWidth = 0.5
        addButton.layer.borderColor = #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1)
        addButton.clipsToBounds = true
        
        registerForKeyboardNotification()
        
        setupToHideKeyboardOnTapOnView()
        
        activityIndicator.startAnimating()
        
        getOptions()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
               
        tableView.register(UINib(nibName: String(describing: OptionCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: OptionCell.self))
        
        optionTextField.delegate = self
        
        addTargetTo(textField: optionTextField)
        
        guard let id = room?.id else { return }
        
        SocketService.shared.connectToOptions(with: id) // подключаемся к сокету опций
        
        self.getData() //запускаем получение данных по сокету
        
        SocketService.shared.setStartVotingCompletion { [weak self] in
            guard
                let self = self,
                let roomID = self.room?.id
            else { return }
            
            let newVS = VotingViewController.makeVC(with: self.options, roomID: roomID, isCreator: self.isUserCreator)
            self.navigationController?.pushViewController(newVS, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isUserCreator {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startVoting(sender:)))
        }
        
        let barItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(returnToRootController(sender:)))
        navigationItem.setLeftBarButton(barItem, animated: true)
        
        SocketService.shared.setExitCompletion { [weak self] in
            self?.exitAlert()
        }
    }
    
    deinit {
        SocketService.shared.disconnectFromOption()
        removeKeyboardNotification()
    }
    
    //MARK: Selectors
    
    var isUserCreator: Bool {
        return room?.creatorID == UserAuthorization.shared.user?.id
    }
    
    @objc func returnToRootController(sender: UIBarButtonItem) {
        if isUserCreator {
            if let id = room?.id {
                RoomsService.shared.deleteRoom(with: id)
                SocketService.shared.exit(with: id)
            }
        }
        SocketService.shared.disconnectFromOption()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func startVoting(sender: UIBarButtonItem) {
        guard let id = room?.id else { return }
        SocketService.shared.startVoting(with: id)
    }
    
    func addTargetTo(textField: UITextField) {
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    func getOptions() {
        
        OptionsService.shared.getOptionsByRoomID( roomID: room?.id, errorCompletion: { [ weak self] (message) in
            self?.activityIndicator.stopAnimating()
            self?.badURLAlert(message: message)
        }) { [ weak self ] (options) in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.activate(views: self.optionTextField)
            self.options = options.sorted { (first, second) -> Bool in
                return first.content.compare(second.content, options: .numeric) == .orderedAscending
            }
            self.tableView.reloadData()
        }
    }
    
    private func getData() {
        SocketService.shared.setOptionCompletion { [weak self] (option) in
            self?.options.append(option)
            self?.options.sort { (first, second) -> Bool in
                return first.content.compare(second.content, options: .numeric) == .orderedAscending
            }
            self?.tableView.reloadData()
        }
    }
    
    static func makeVC(with room: Room ) -> RoomViewController {
        
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: RoomViewController.self)) as? RoomViewController
        
        guard let newVC = newViewController else {return RoomViewController()}
        
        newVC.room = room

        return newVC
    }
    
    //MARK: Alerts
    
    func badURLAlert(message: String){
        
        let allert = UIAlertController(title: "Error occurred", message: message + " Press OK to retry.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.getOptions()
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
    
    func badCreatingURLAlert(message: String){
        
        activate(views: optionTextField, addButton)
        
        let allert = UIAlertController(title: "Error occurred", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
    
    func successAlert(){
        
        activate(views: optionTextField)
        
        let allert = UIAlertController(title: "Success", message: "Your option added successfully!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.optionTextField.text = ""
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
}

extension RoomViewController: UITextFieldDelegate{
    
    //To close the keyboard after Done pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        
        if areFieldsEmpty()  {
            disable(views: addButton)
        } else {
            activate(views: addButton)
        }
    }
    
    func areFieldsEmpty() -> Bool {
        return optionTextField.text?.isEmpty ?? true
    }
    
}

//MARK: Tabele

extension RoomViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

extension RoomViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let option = options[indexPath.row]
        
        let identifier = String(describing: OptionCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? OptionCell else { return OptionCell() }
        
        cell.configure(with: option)
        
        return cell
    }
    
    
}



//MARK: Show the content above the keyboard

extension RoomViewController{
    
    func registerForKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y + keyboardSize.size.height), animated: true)
            self.view.frame.size.height -= keyboardSize.size.height
            
        }
    }
    

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.size.height += keyboardSize.size.height
            //tableView.setContentOffset(CGPoint(x: 0, y:             tableView.contentOffset.y - keyboardSize.height), animated: true)
        }
    }
}
