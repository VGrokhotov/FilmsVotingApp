//
//  RoomService.swift
//  FilmsVoting
//
//  Created by Владислав on 21.05.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

protocol RoomStorage {
    func getRooms(errorCompletion: @escaping (String) -> (), completion: @escaping ([Room]) -> ())
    func create(room: Room, errorCompletion: @escaping (String) -> (), completion: @escaping () -> ())
}

class RoomService: RoomStorage {
    
    let urlString = "https://filmsvotingv2.herokuapp.com/rooms/"
    
    //MARK: GET
    
    func getRooms(errorCompletion: @escaping (String) -> (), completion: @escaping ([Room]) -> ()) {
        
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

                    let response = try? JSONDecoder().decode([Room].self, from: data)
                    if let response = response {
                        
                        DispatchQueue.main.async {
                            completion(response)
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
    
    func deleteRoom(withID: String) {
        //
    }
    
    func updateRoom(withID: String) {
        //
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

}
