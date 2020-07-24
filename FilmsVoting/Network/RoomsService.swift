//
//  RoomsService.swift
//  FilmsVoting
//
//  Created by Владислав on 21.05.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class RoomsService {
    
    public static let shared = RoomsService() // создаем Синглтон
    private init() {}
    
    private let urlString = "https://filmsvotingv2.herokuapp.com/rooms/"
    
    private let scheme = "https"
    private let host = "filmsvotingv2.herokuapp.com"
    private let roomIDPath = "/rooms/id"
    private let roomPath = "/rooms"
    
    //MARK: GET
    
    func getRooms(errorCompletion: @escaping (String) -> (), completion: @escaping ([NotVerifiedRoom]) -> ()) {
        
        let session = URLSession.shared
        let url = URL(string: urlString)
        
        if let url = url {
            
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if let error = error {
                    DispatchQueue.main.async {
                        errorCompletion(error.localizedDescription)
                    }
                } else if let data = data {

                    let rooms = try? JSONDecoder().decode([NotVerifiedRoom].self, from: data)
                    if let rooms = rooms {
                        
                        DispatchQueue.main.async {
                            completion(rooms)
                        }
                    }
                }
            }
            task.resume()
        } else {
            DispatchQueue.main.async {
                errorCompletion("Wrong URL of Rooms source, please, send the sсreenshot of this message to developer")
            }
        }
    }
    
    //MARK: POST
    
    func create(room: Room, errorCompletion: @escaping (String) -> (),  completion: @escaping () -> ()) {

        if  let url = URL(string: urlString) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            guard let httpBody = try? JSONEncoder().encode(room)  else {
                DispatchQueue.main.async {
                    errorCompletion("Wrong structure of new Room, please, send the sсreenshot of this message to developer")
                }
                return
            }
            
            request.httpBody = httpBody
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if let error = error {
                    DispatchQueue.main.async {
                        errorCompletion(error.localizedDescription)
                    }
                } else if let data = data {
                    let newRoom = try? JSONDecoder().decode(Room.self, from: data)
                    if let /*newRoom*/ _ = newRoom {
                        DispatchQueue.main.async {
                            //мб чето сделать с вернувшейся комнатой, пока не понятно
                            completion()
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorCompletion("Wrong JSON data from POSTing of room, please, send the sсreenshot of this message to developer")
                        }
                    }
                }
            }
            task.resume()
            
            
            
        } else {
            DispatchQueue.main.async {
                errorCompletion("Wrong URL of Rooms source, please, send the sсreenshot of this message to developer")
            }
        }
    }
    
    func getRoomByIDWithPassword(id: UUID?, password: String, errorCompletion: @escaping (String) -> (), completion: @escaping (Room) -> ()) {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = roomIDPath
        
        let url = components.url

        if let url = url {

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let authorizationRoom = AuthorizationRoom(id: id, password: password)
            guard let httpBody = try? JSONEncoder().encode(authorizationRoom)  else {
                DispatchQueue.main.async {
                    errorCompletion("Wrong structure of AuthorizationRoom, please, send the sсreenshot of this message to developer")
                }
                return
            }
            
            request.httpBody = httpBody
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        errorCompletion(error.localizedDescription)
                    }
                } else if let data = data {

                    let room = try? JSONDecoder().decode(Room.self, from: data)
                    if let room = room {
                        DispatchQueue.main.async {
                            completion(room)
                        }
                    } else {
                        let dataError = try? JSONDecoder().decode(Error.self, from: data)
                        if let dataError = dataError {
                            DispatchQueue.main.async {
                                errorCompletion(dataError.reason)
                            }
                        } else {
                            DispatchQueue.main.async {
                                errorCompletion("Wrong Room data from server, please, send the sсreenshot of this message to developer")
                            }
                        }
                        
                    }
                }
            }
            task.resume()
        } else {
            DispatchQueue.main.async {
                errorCompletion("Wrong URL of Rooms source, please, send the sсreenshot of this message to developer")
            }
        }
    }
    
    
    //MARK: Delete
    
    func deleteRoom(with id: UUID) {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = roomPath
        
        if  let url = components.url {
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let roomID = RoomID(id: id)
            
            guard let httpBody = try? JSONEncoder().encode(roomID)  else {
                print("Wrong structure of RoomID, please, send the sсreenshot of this message to developer")
                return
            }
            
            request.httpBody = httpBody
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Deleted \(roomID)")
                }
            }
            task.resume()
            
            
            
        } else {
            print("Wrong URL of Room source, please, send the sсreenshot of this message to developer")
        }
        
    }

}
