//
//  SocketService.swift
//  FilmsVoting
//
//  Created by Владислав on 22.07.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import Foundation

class SocketService {
    public static let shared = SocketService() // создаем Синглтон
    private init(){}
    
    private var optionCompletion: ((Option) -> Void)?
    private var roomCompletion: ((NotVerifiedRoom) -> Void)?
    private var starVotingCompletion: (() -> Void)?
    
    func setOptionCompletion(completion: @escaping (Option) -> Void ) {
        optionCompletion = completion
    }
    
    func setRoomCompletion(completion: @escaping (NotVerifiedRoom) -> Void ) {
        roomCompletion = completion
    }
    
    func setStartVotingCompletion(completion: @escaping () -> Void ) {
        starVotingCompletion = completion
    }
    
    //"ws://127.0.0.1:8080/socket"
    //"ws://filmsvotingv2.herokuapp.com/socket"
    private let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://filmsvotingv2.herokuapp.com/socket")!)
    
    public func connectToRooms() {
        webSocketTask.resume()
        
        let message = Message(type: .connectRoom, content: nil)
        if let messageData = try? JSONEncoder().encode(message) {
            webSocketTask.send(URLSessionWebSocketTask.Message.data(messageData)) { (error) in
                if let error = error {
                    print("cannot send message because of \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func connectToOptions(with roomID: UUID) {
        webSocketTask.resume()
        
        guard let content = roomID.uuidString.data(using: .utf8) else { return }
        
        let message = Message(type: .connectOption, content: content)
        if let messageData = try? JSONEncoder().encode(message) {
            webSocketTask.send(URLSessionWebSocketTask.Message.data(messageData)) { (error) in
                if let error = error {
                    print("cannot send message because of \(error.localizedDescription)")
                }
            }
        }
    }
    
    //отключаемся на сервере
    public func disconnectFromWebSocket(){
        
        let message = Message(type: .disconnect, content: nil)
        if let messageData = try? JSONEncoder().encode(message) {
            webSocketTask.send(URLSessionWebSocketTask.Message.data(messageData)) { (error) in
                if let error = error {
                    print("cannot send message because of \(error.localizedDescription)")
                }
            }
        }
        webSocketTask.cancel(with: .goingAway, reason: nil)
    }
    
    public func disconnectFromOption(){
        
        let message = Message(type: .disconnectFromOption, content: nil)
        if let messageData = try? JSONEncoder().encode(message) {
            webSocketTask.send(URLSessionWebSocketTask.Message.data(messageData)) { (error) in
                if let error = error {
                    print("cannot send message because of \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func startVoting(with roomID: UUID) {
        
        guard let content = roomID.uuidString.data(using: .utf8) else { return }
        
        let message = Message(type: .startVoting, content: content)
        if let messageData = try? JSONEncoder().encode(message) {
            webSocketTask.send(URLSessionWebSocketTask.Message.data(messageData)) { (error) in
                if let error = error {
                    print("cannot send message because of \(error.localizedDescription)")
                }
            }
        }
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
    //функция получения новой комнаты, с эскейпингом чтобы получить комнату наружу
    func receiveData() {
        
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                print("success receive")
                switch message {
                case .string(let text):
                    print("Received text: \(text)")
                case .data(let data):
                    print("Received data: \(data)")
                    
                    if let message = try? JSONDecoder().decode(Message.self, from: data) {
                        switch message.type {
                        case .option:
                            
                            if
                                let data = message.content,
                                let option = try? JSONDecoder().decode(Option.self, from: data) {
                                print("Option, \(option)")
                                DispatchQueue.main.async { [weak self] in
                                    self?.optionCompletion?(option)
                                }
                            }
                        case .room:
                            if
                                let data = message.content,
                                let room = try? JSONDecoder().decode(NotVerifiedRoom.self, from: data) {
                                print("Room, \(room)")
                                DispatchQueue.main.async { [weak self] in
                                    self?.roomCompletion?(room)
                                }
                            }
                        case .startVoting:
                            self.starVotingCompletion?()
                        default:
                            break
                        }
                    }
                    
                @unknown default:
                    debugPrint("Unknown message")
                }
                
                self.receiveData() // рекурсия
            }
        }
    }
}
