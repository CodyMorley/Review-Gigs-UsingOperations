//
//  PostGigOperation.swift
//  Gigs
//
//  Created by Cody Morley on 8/9/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import Foundation

class PostGigOperation: ConcurrentOperation {
    var request: URLRequest
    
    
    init(request: URLRequest) {
        self.request = request
    }
    
    override func start () {
        NSLog("Beginning post Operation.")
        state = .isExecuting
        
        switch isCancelled {
        case true:
            state = .isFinished
            return
        case false:
            break
        }
        
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            defer {
                self.state = .isFinished
                NSLog("Finishing post Op.")
            }
            
            if let error = error {
                NSLog("Something went wrong posting your gig to the remote host. Here's what happened: \(error) \(error.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    NSLog("Bad or no response from server when posting your gig.")
                    return
            }
        }.resume()
    }
    
    override func cancel() {
        super.cancel()
    }
}
