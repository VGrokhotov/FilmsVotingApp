//
//  UserService.swift
//  FilmsVoting
//
//  Created by Владислав on 18.06.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class UsersService {
    
    public static let shared = UsersService() // создаем Синглтон
    private init() {}
    
    private let urlString = "https://filmsvotingv2.herokuapp.com/users/"
    
    private let scheme = "https"
    private let host = "filmsvotingv2.herokuapp.com"
    private let loginPath = "/users/login/"
    
    //MARK: GET
    
    func getUserByLoginWithPassword(login: String, password: String, errorCompletion: @escaping (String) -> (), completion: @escaping (User) -> ()) {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = loginPath + login
        components.queryItems = [ URLQueryItem(name: "password", value: password) ]
        
        let url = components.url

        if let url = url {

            let request = URLRequest(url: url)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { (data, response, error) in

                if let error = error {
                    DispatchQueue.main.async {
                        errorCompletion(error.localizedDescription)
                    }
                } else if let data = data {

                    let user = try? JSONDecoder().decode(User.self, from: data)
                    if let user = user {

                        DispatchQueue.main.async {
                            completion(user)
                        }
                    }
                }
            }
            task.resume()
        } else {
            DispatchQueue.main.async {
                errorCompletion("Wrong URL of Users source, please, send the sсreenshot of this message to developer")
            }
        }
    }
//
//    func deleteUser(withID: String) {
//        //
//    }
//
//    func updateUser(withID: String) {
//        //
//    }
    
    //MARK: POST
    func create(user: User, errorCompletion: @escaping (String) -> (),  completion: @escaping () -> ()) {

        if  let url = URL(string: urlString) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            guard let httpBody = try? JSONEncoder().encode(user)  else {
                DispatchQueue.main.async {
                    errorCompletion("Wrong structure of new User, please, send the sсreenshot of this message to developer")
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
                    let newUser = try? JSONDecoder().decode(User.self, from: data)
                    if let /*newUser*/ _ = newUser {
                        DispatchQueue.main.async {
                            //мб чето сделать с вернувшимся юзером, пока не понятно
                            completion()
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorCompletion("Wrong JSON data from POSTing of user, please, send the sсreenshot of this message to developer")
                        }
                    }
                }
            }
            task.resume()
            
            
            
        } else {
            DispatchQueue.main.async {
                errorCompletion("Wrong URL of user source, please, send the sсreenshot of this message to developer")
            }
        }
    }

}
