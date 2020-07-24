//
//  VotingViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 23.07.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class VotingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var voteButton: UIButton!
    
    
    private var options: [OptionWithSelection] = []
    private var isCreator: Bool = false
    private var roomID: UUID = UUID()

    
    @IBAction func voteButtonPressed(_ sender: Any) {
        disable(views: voteButton)
        for option in options {
            if option.selected {
                if let id = option.id {
                    OptionsService.shared.updateOption(with: id) { [weak self] (str) in
                        self?.badAlert(message: str)
                    }
                }
            }
        }
        if !isCreator {
            let newVC = ResultViewController.makeVC(isCreator: isCreator, roomID: roomID)
            
            navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        voteButton.layer.cornerRadius = 15
        voteButton.layer.borderWidth = 0.5
        voteButton.layer.borderColor = #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1)
        voteButton.clipsToBounds = true
        
        title = "Voting"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
               
        tableView.register(UINib(nibName: String(describing: VotingCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: VotingCell.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isCreator {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "stop.fill"), style: .plain, target: self, action: #selector(endVoting(sender:)))
        }
        
        let barItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(returnToRootController(sender:)))
        navigationItem.setLeftBarButton(barItem, animated: true)
        
    }
    
    deinit {
        SocketService.shared.disconnectFromOption()
    }
    
    @objc func returnToRootController(sender: UIBarButtonItem) {
        if isCreator {
            RoomsService.shared.deleteRoom(with: roomID)
            SocketService.shared.exit(with: roomID)
        }
        SocketService.shared.disconnectFromOption()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func endVoting(sender: UIBarButtonItem) {
        let newVC = ResultViewController.makeVC(isCreator: isCreator, roomID: roomID)
            
        navigationController?.pushViewController(newVC, animated: true)
        
        SocketService.shared.endVoting(with: roomID)
    }
    
    static func makeVC(with options: [Option], roomID: UUID, isCreator: Bool ) -> VotingViewController {
        
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: VotingViewController.self)) as? VotingViewController
        
        guard let newVC = newViewController else { return VotingViewController() }
        
        newVC.options = options.map({ (option) -> OptionWithSelection in
            return option.toOptionWithSelection()
        })
        newVC.isCreator = isCreator
        newVC.roomID = roomID

        return newVC
    }
    
    //MARK: Alerts
    
    func badAlert(message: String){
        
        let allert = UIAlertController(title: "Error occurred", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }

}


//MARK: Tabele

extension VotingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as? VotingCell
        guard let type = cell?.accessoryType else { return }
        
        switch type {
        case .checkmark:
            cell?.accessoryType = .none
            options[indexPath.row].selected = false
        case .none:
            cell?.accessoryType = .checkmark
            options[indexPath.row].selected = true
        default:
            break
        }
    }
}

extension VotingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let option = options[indexPath.row]
        
        let identifier = String(describing: VotingCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? VotingCell else { return VotingCell() }
        
        cell.configure(with: option)
        
        return cell
    }
    
    
}
