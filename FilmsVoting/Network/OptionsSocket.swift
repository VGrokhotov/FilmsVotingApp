//
//  OptionsSocket.swift
//  FilmsVoting
//
//  Created by Владислав on 21.07.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import Foundation

class OptionsSocket {

    init(){}
    
    //"ws://127.0.0.1:8080/options/socket"
    //"ws://filmsvotingv2.herokuapp.com/options/socket"
    private let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://filmsvotingv2.herokuapp.com/options/socket")!)
    
    //функция вызова подключения
    public func connectToWebSocket(with roomID: UUID) {
        webSocketTask.resume()
        
        webSocketTask.send(URLSessionWebSocketTask.Message.string("Connect, \(roomID)")) { (error) in
            if let error = error {
                print("cannot send message because of \(error.localizedDescription)")
            }
        }
    }
    
    //отключаемся на сервере
    public func disconnectFromWebSocket(){
        
        webSocketTask.send(URLSessionWebSocketTask.Message.string("Disconnect")) { (error) in
            if let error = error {
                print("cannot send message because of \(error.localizedDescription)")
            }
        }
        
        webSocketTask.cancel(with: .goingAway, reason: nil)
    }
    
    func ping() {
        webSocketTask.sendPing { (error) in
            if let error = error {
                print("Ping failed: \(error)")
            } else {
                self.scheduleNextPing()
            }
        }
    }

    private func scheduleNextPing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.ping()
        }
    }
    
    //функция получения новой опции, с эскейпингом чтобы получить комнату наружу
    func receiveData(completion: @escaping (Option) -> Void) {
        
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
                        let option = try? JSONDecoder().decode(Option.self, from: data)
                        if let option = option {
                            DispatchQueue.main.async {
                                completion(option)// отправляем в комплишн то что насобирали в нашу модель
                            }
                        }
                    }
                    
                                        
                case .data(let data):
                    print("Received data: \(data)")
                    
                @unknown default:
                    debugPrint("Unknown message")
                }
                
                self.receiveData(completion: completion) // рекурсия
            }
        }
    }
}
