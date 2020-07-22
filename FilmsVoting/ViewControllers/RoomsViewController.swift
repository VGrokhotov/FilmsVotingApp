//
//  ViewController.swift
//  FilmsVoting
//
//  Created by Владислав on 19.04.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class RoomsViewController: UIViewController {

    private var rooms: [NotVerifiedRoom] = []
    private var isRoomWebSocketConnected = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newRoomButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
               
        tableView.register(UINib(nibName: String(describing: RoomCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: RoomCell.self))
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkAuthorization()
    }
    
    deinit {
        isRoomWebSocketConnected = false
        SocketService.shared.disconnectFromWebSocket()
    }
    
    func checkAuthorization() {
        if UserAuthorization.shared.isAuthorized {
            isAuthorized()
        } else {
            isNotAuthorized()
        }
    }
    
    func isNotAuthorized(){
        tableView.isHidden = true
        newRoomButton.isEnabled = false
        rooms = []
        authorizationAlert()
        
        SocketService.shared.disconnectFromWebSocket()
        isRoomWebSocketConnected = false
        self.getData() //запускаем получение данных по сокету
    }
    
    func isAuthorized(){
        tableView.isHidden = false
        newRoomButton.isEnabled = true
        
        activityIndicator.startAnimating()
        
        RoomsService.shared.getRooms(errorCompletion: { [ weak self] (message) in
            self?.activityIndicator.stopAnimating()
            self?.badURLAlert(message: message)
        }) { [ weak self ] (rooms) in
            self?.activityIndicator.stopAnimating()
            self?.rooms = rooms
            self?.tableView.reloadData()
        }
        
        if isRoomWebSocketConnected {
            isRoomWebSocketConnected = true
            SocketService.shared.connectToRooms() // подключаемся к сокету комнат
            SocketService.shared.ping()
            
            self.getData() //запускаем получение данных по сокету
        }
        
    }
    
    private func getData() {
        SocketService.shared.setRoomCompletion { [weak self] (room) in
            self?.rooms.append(room)
            self?.tableView.reloadData()
        }
        SocketService.shared.receiveData()
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
        
        let allert = UIAlertController(title: "Error occurred", message: message + " Press OK to retry.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            RoomsService.shared.getRooms(errorCompletion: { [ weak self] (message) in
                self?.activityIndicator.stopAnimating()
                self?.badURLAlert(message: message)
            }) { [ weak self ] (rooms) in
                self?.activityIndicator.stopAnimating()
                self?.rooms = rooms
                self?.tableView.reloadData()
            }
        }
        
        allert.addAction(okAction)
        present(allert, animated: true)
    }

}

//MARK: Tabele

extension RoomsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard
            let notVerifiedRoomCell = tableView.cellForRow(at: indexPath) as? RoomCell,
            let notVerifiedRoom = notVerifiedRoomCell.notVerifiedRoom
        else { return }
        
        let destinationViewController = RoomEnteringViewController.makeVC(with: notVerifiedRoom)
        
        navigationController?.pushViewController(destinationViewController, animated: true)
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
