//
//  OptionsService.swift
//  FilmsVoting
//
//  Created by Владислав on 22.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class OptionsService {
    
    public static let shared = OptionsService() // создаем Синглтон
    private init() {}
    
    private let scheme = "https"
    private let host = "filmsvotingv2.herokuapp.com"
    private let optionsPath = "/options"
    private let selectorPath = "/roomid"
    
    //MARK: PUT
    
    func updateOption(with id: UUID, errorCompletion: @escaping (String) -> ()) {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = optionsPath

        if  let url = components.url {
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let optionID = OptionID(id: id)
            
            guard let httpBody = try? JSONEncoder().encode(optionID)  else {
                DispatchQueue.main.async {
                    errorCompletion("Wrong structure of OptionID, please, send the sсreenshot of this message to developer")
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
                } else {
                    print("Voted for \(optionID)")
                }
            }
            task.resume()
            
        } else {
            DispatchQueue.main.async {
                errorCompletion("Wrong URL of Option source, please, send the sсreenshot of this message to developer")
            }
        }
    }
    
    
    //MARK: POST
    
    
    func create(option: Option, errorCompletion: @escaping (String) -> (),  completion: @escaping () -> ()) {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = optionsPath

        if  let url = components.url {
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            guard let httpBody = try? JSONEncoder().encode(option)  else {
                DispatchQueue.main.async {
                    errorCompletion("Wrong structure of new Option, please, send the sсreenshot of this message to developer")
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
                    let newOption = try? JSONDecoder().decode(Option.self, from: data)
                    if let /*newOption*/ _ = newOption {
                        DispatchQueue.main.async {
                            //мб чето сделать с вернувшейся опцией, пока не понятно
                            completion()
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorCompletion("Wrong JSON data from POSTing of option, please, send the sсreenshot of this message to developer")
                        }
                    }
                }
            }
            task.resume()
            
            
            
        } else {
            DispatchQueue.main.async {
                errorCompletion("Wrong URL of Option source, please, send the sсreenshot of this message to developer")
            }
        }
    }
    
    func getOptionsByRoomID(roomID: UUID?, errorCompletion: @escaping (String) -> (), completion: @escaping ([Option]) -> ()) {
        
        guard let roomID = roomID else {
            DispatchQueue.main.async {
                errorCompletion("Wrong roomID, please, send the sсreenshot of this message to developer")
            }
            return
        }
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = optionsPath + selectorPath
        
        let url = components.url

        if let url = url {

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let optionSelecor = OptionSelector(roomID: roomID)
            
            guard let httpBody = try? JSONEncoder().encode(optionSelecor)  else {
                DispatchQueue.main.async {
                    errorCompletion("Wrong structure of OptionSelector, please, send the sсreenshot of this message to developer")
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

                    let options = try? JSONDecoder().decode([Option].self, from: data)
                    if let options = options {
                        DispatchQueue.main.async {
                            completion(options)
                        }
                    } else {
                        let dataError = try? JSONDecoder().decode(Error.self, from: data)
                        if let dataError = dataError {
                            DispatchQueue.main.async {
                                errorCompletion(dataError.reason)
                            }
                        } else {
                            DispatchQueue.main.async {
                                errorCompletion("Wrong Option data from server, please, send the sсreenshot of this message to developer")
                            }
                        }
                        
                    }
                }
            }
            task.resume()
        } else {
            DispatchQueue.main.async {
                errorCompletion("Wrong URL of Option source, please, send the sсreenshot of this message to developer")
            }
        }
    }
    
    //MARK: Delete
    
    func deleteOption(with id: UUID, errorCompletion: @escaping (String) -> ()) {
        
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = optionsPath
        
        if  let url = components.url {
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let optionID = OptionID(id: id)
            
            guard let httpBody = try? JSONEncoder().encode(optionID)  else {
                DispatchQueue.main.async {
                    errorCompletion("Wrong structure of OptionID, please, send the sсreenshot of this message to developer")
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
                } else {
                    print("Deleted \(optionID)")
                }
            }
            task.resume()
            
            
            
        } else {
            DispatchQueue.main.async {
                errorCompletion("Wrong URL of Option source, please, send the sсreenshot of this message to developer")
            }
        }
        
    }

}
