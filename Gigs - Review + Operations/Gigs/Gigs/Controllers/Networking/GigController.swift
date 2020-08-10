//
//  GigController.swift
//  Gigs
//
//  Created by Cody Morley on 8/5/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import Foundation

class GigController {
    //MARK: - Types -
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    
    //MARK: - Properties -
    var bearer: Bearer?
    var gigs: [Gig] = []
    private var baseURL = URL(string: "https://lambdagigs.vapor.cloud/api")!
    lazy private var gigsQueue = OperationQueue()
    lazy private var gigURL = baseURL.appendingPathComponent("/gigs/")
    private var decoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        return jsonDecoder
    }
    private var encoder: JSONEncoder {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        return jsonEncoder
    }
    
    
    //MARK: - Actions -
    func fetchGigs() { //TODO: Add a completion handler closure to this instance method.
        let request = gigFetchRequest(gigURL)
        let fetchOp = FetchGigsOperation(request: request)
        let decodeDataOp = BlockOperation {
            guard let data = fetchOp.data else { return }
            do {
                let decodedGigs = try self.decoder.decode([Gig].self, from: data)
                self.gigs = decodedGigs
            } catch {
                NSLog("Unable to decode gigs from returned data. Here's what went wrong: \(error) \(error.localizedDescription)")
                return
            }
        }
        let finishFetchOp = BlockOperation {
            NSLog("Fetch finished.")
        }
        decodeDataOp.addDependency(fetchOp)
        finishFetchOp.addDependency(decodeDataOp)
        gigsQueue.addOperations([fetchOp,decodeDataOp,finishFetchOp],
                                waitUntilFinished: false)
    }
    
    func postGig(_ gig: Gig) {
        var request = gigPostRequest(gigURL)
        
        do{
            let encodedGig = try self.encoder.encode(gig)
            request.httpBody = encodedGig
        } catch {
            NSLog("Unable to encode gig. Here's what happened: \(error) \(error.localizedDescription)")
            return
        }
        
        let postOp = PostGigOperation(request: request)
        let finishPostOp = BlockOperation {
            NSLog("Finished Posting")
        }
        finishPostOp.addDependency(postOp)
        gigsQueue.addOperations([postOp, finishPostOp],
                                waitUntilFinished: false)
        
    }
    
    
    //MARK: - Methods -
    private func gigFetchRequest(_ url: URL) -> URLRequest {
        var fetchRequest = URLRequest(url: url)
        fetchRequest.httpMethod = HTTPMethod.get.rawValue
        fetchRequest.addValue(bearer!.token, forHTTPHeaderField: "Authorization")
        return fetchRequest
    }
    
    private func gigPostRequest(_ url: URL) -> URLRequest {
        var postRequest = URLRequest(url: url)
        postRequest.httpMethod = HTTPMethod.post.rawValue
        postRequest.addValue(bearer!.token, forHTTPHeaderField: "Authorization")
        return postRequest
    }
}
