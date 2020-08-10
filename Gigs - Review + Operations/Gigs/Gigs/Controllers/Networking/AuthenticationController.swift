//
//  AuthenticationController.swift
//  Gigs
//
//  Created by Cody Morley on 8/5/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import Foundation

class AuthenticationController {
    //MARK: - Properties -
    var authenticationQueue = OperationQueue()
    var delegate: AuthenticationControllerDelegate?
    var bearer: Bearer? {
        didSet {
            delegate?.setBearer()
        }
    }
    private var baseURL = URL(string: "https://lambdagigapi.herokuapp.com/api")!
    
    
    //MARK: - Actions -
    func signUp(_ user: User) {
        let url = baseURL.appendingPathComponent("/users/signup")
        let request = getRequest(url)
        let signUpOp = SignupOperation(request: request,
                                       for: user)
        let finishSignUpOp = BlockOperation {
            NSLog("Finished Signup.")
        }
        finishSignUpOp.addDependency(signUpOp)
        authenticationQueue.addOperations([signUpOp, finishSignUpOp],
                                          waitUntilFinished: false)
    }
    
    func logIn(_ user: User) {
        let url = baseURL.appendingPathComponent("/users/login")
        let request = getRequest(url)
        let loginOp = LoginOperation(request: request,
                                     for: user)
        let finishLoginOp = BlockOperation {
            self.bearer = loginOp.bearer
            NSLog("Finished Login.")
        }
        finishLoginOp.addDependency(loginOp)
        authenticationQueue.addOperations([loginOp, finishLoginOp],
                                          waitUntilFinished: false)
    }
    
    
    //MARK: - Methods -
    private func getRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        return request
    }
}
