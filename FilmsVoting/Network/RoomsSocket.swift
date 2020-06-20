//
//  RoomsSocket.swift
//  FilmsVoting
//
//  Created by Владислав on 24.04.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import Foundation

class RoomsSocket {
    public static let shared = RoomsSocket() // создаем Синглтон
    private init(){}
    
    //"ws://127.0.0.1:8080/rooms/socket"
    //"ws://filmsvotingv2.herokuapp.com/rooms/socket"
    private let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://filmsvotingv2.herokuapp.com/rooms/socket")!)
    
    //функция вызова подключения
    public func connectToWebSocket() {
        webSocketTask.resume()
        
        webSocketTask.send(URLSessionWebSocketTask.Message.string("Connect")) { (error) in
            if let error = error {
                print("cannot send message because of \(error.localizedDescription)")
            }
        }
    }
    
    //отключаемся на сервере
    public func disconnectFromWebSocket(){
        webSocketTask.resume()
        
        webSocketTask.send(URLSessionWebSocketTask.Message.string("Disconnect")) { (error) in
            if let error = error {
                print("cannot send message because of \(error.localizedDescription)")
            }
        }
    }
    
    
    //функция получения новой комнаты, с эскейпингом чтобы получить комнату наружу
    func receiveData(completion: @escaping (NotVerifiedRoom) -> Void) {
        
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                print("success receive")
                switch message {
                case .string(let text):
                    print("Received text: \(text)")
                    
                    if  let data = text.data(using: .utf8) {
                        let room = try? JSONDecoder().decode(NotVerifiedRoom.self, from: data)
                        if let room = room {
                            DispatchQueue.main.async {
                                completion(room)// отправляем в комплишн то что насобирали в нашу модель
                            }
                        }
                    }
                    
                                        
                case .data(let data):
                    print("Received data: \(data)")
                    
                @unknown default:
                    debugPrint("Unknown message")
                }
                
                //self.receiveData(completion: completion) // рекурсия
            }
        }
    }
}
