//
//  ResultViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 24.07.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var options: [Option] = []
    
    private var isCreator: Bool = false
    private var roomID: UUID = UUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Results"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
               
        tableView.register(UINib(nibName: String(describing: ResultCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: ResultCell.self))
        
        activityIndicator.startAnimating()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SocketService.shared.setEndVotingCompletion { [weak self ] in
            self?.getTopOptions()
        }
        
        let barItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(returnToRootController(sender:)))
        navigationItem.setLeftBarButton(barItem, animated: true)
    }
    
    deinit {
        SocketService.shared.disconnectFromOption()
    }
    
    func getTopOptions() {
        OptionsService.shared.getTopOptionsByRoomID(roomID: roomID, errorCompletion: { [weak self] (message) in
            self?.activityIndicator.stopAnimating()
            self?.badAlert(message: message)
        }) { [weak self] (options) in
            self?.activityIndicator.stopAnimating()
            self?.options = options.sorted(by: { (first, second) -> Bool in
                return first.vote > second.vote
            })
            self?.tableView.reloadData()
        }
    }
    
    @objc func returnToRootController(sender: UIBarButtonItem) {
        if isCreator {
            RoomsService.shared.deleteRoom(with: roomID)
            SocketService.shared.exit(with: roomID)
        }
        SocketService.shared.disconnectFromOption()
        navigationController?.popToRootViewController(animated: true)
    }
    
    static func makeVC(isCreator: Bool, roomID: UUID ) -> ResultViewController {
        
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: ResultViewController.self)) as? ResultViewController
        
        guard let newVC = newViewController else { return ResultViewController() }
        
        newVC.isCreator = isCreator
        newVC.roomID = roomID

        return newVC
    }
    
    //MARK: Alerts
    
    func badAlert(message: String){
        
        let allert = UIAlertController(title: "Error occurred", message: message + " Press OK to retry.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.activityIndicator.startAnimating()
            self?.getTopOptions()
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }

}

//MARK: Tabele

extension ResultViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

extension ResultViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let option = options[indexPath.row]
        
        let identifier = String(describing: ResultCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ResultCell else { return ResultCell() }
        
        cell.configure(with: option)
        
        return cell
    }
    
    
}
