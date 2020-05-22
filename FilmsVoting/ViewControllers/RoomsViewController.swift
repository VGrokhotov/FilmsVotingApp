//
//  ViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 19.04.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class RoomsViewController: UIViewController {
    
    var authorized = true // заглушка
    
    private let roomsService: RoomStorage = RoomService()
    
    private var rooms: [Room] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newRoomButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !authorized {
            isNotAuthorized()
        } else {
            activityIndicator.startAnimating()
            roomsService.getRooms(errorCompletion: { [ weak self] (message) in
                self?.activityIndicator.stopAnimating()
                self?.badURLAlert(message: message)
            }) { [ weak self ] (rooms) in
                self?.activityIndicator.stopAnimating()
                self?.rooms = rooms
                self?.tableView.reloadData()
            }
            
            self.getData() //запускаем получение данных по сокету
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
               
        tableView.register(UINib(nibName: String(describing: RoomCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: RoomCell.self))
        
    }
    
    func isNotAuthorized(){
        tableView.isHidden = true
        newRoomButton.isEnabled = false
        authorizationAlert()
    }
    
    private func getData() {
        RoomsSocket.shared.receiveData() { [weak self] (room) in
            guard
                let self = self
            else { return }
            
            self.rooms.append(room)
            self.tableView.reloadData()
        }
    }
    
    //MARK: Alerts
    
    func authorizationAlert(){
        
        let allert = UIAlertController(title: "You are not authorized", message: "To see rooms, please, authorize", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
    
    func badURLAlert(message: String){
        
        let allert = UIAlertController(title: "Error occurred", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }
        
    //MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewRoom" {
//            let newRoom = segue.destination as? NewRoomViewController
            
//            newRoom?.roomsService = roomsService
        }
    }

}

//MARK: Tabele

extension RoomsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
//        guard let room = tableView.cellForRow(at: indexPath) else { return }
//        
//        let destinationViewController = RoomViewController.makeVC(with: room)
//        
//        navigationController?.pushViewController(destinationViewController, animated: true)
    }
}

extension RoomsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let room = rooms[indexPath.row]
        
        let identifier = String(describing: RoomCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? RoomCell else { return RoomCell() }
        
        cell.configure(with: room)
        
        return cell
    }
    
    
}
