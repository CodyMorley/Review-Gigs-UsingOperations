//
//  LoginOperation.swift
//  Gigs
//
//  Created by Cody Morley on 8/9/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import Foundation

class LoginOperation: ConcurrentOperation {
    private var request: URLRequest
    private var user: User
    var bearer: Bearer?
    
    init(request: URLRequest, for user: User) {
        self.request = request
        self.user = user
    }
    
    override func start() {
        NSLog("Beginning login Operation for user \(user.username)")
        state = .isExecuting
        
        switch isCancelled {
        case true:
            state = .isFinished
            return
        case false:
            break
        }
        
        do {
            let loginData = try JSONEncoder().encode(user)
            request.httpBody = loginData
        } catch {
            NSLog("Error encoding: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                self.state = .isFinished
                NSLog("Finishing Signup Op for user: \(self.user.username).")
            }
            
            if let error = error {
                NSLog("Something has gone wrong during login. Here's some info: \(error) \(error.localizedDescription)")
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    NSLog("Bad or no response from host on signup.")
                    return
            }
            
            guard let data = data else {
                NSLog("No data returned on login.")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Bearer.self,
                                                      from: data)
                self.bearer = result
                print("SUCCESS!")
            } catch {
                NSLog("Something happened decoding your bearer token, here's some info: \(error)")
                return
            }
        }.resume()
    }
    
    override func cancel() {
        super.cancel()
    }
}
