//
//  FetchGigsOperation.swift
//  Gigs
//
//  Created by Cody Morley on 8/9/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import Foundation

class FetchGigsOperation: ConcurrentOperation {
    private var request: URLRequest
    var data: Data?
    
    init(request: URLRequest) {
        self.request = request
    }
    
    
    override func start() {
        NSLog("Beginning fetch Operation.")
        state = .isExecuting
        
        switch isCancelled {
        case true:
            state = .isFinished
            return
        case false:
            break
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                self.state = .isFinished
                NSLog("Finishing Fetch Op.")
            }
            
            if let error = error {
                NSLog("Something happened with your fetch request. \(error) \(error.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    NSLog("Bad or no response from host when fetching gigs.")
                    return
            }
            
            guard let data = data else {
                NSLog("There was no data returned from the host when fetching gigs.")
                return
            }
            self.data = data
        }.resume()
    }
    
    override func cancel() {
        super.cancel()
    }
}
