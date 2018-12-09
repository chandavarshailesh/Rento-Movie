//
//  RequestManager.swift
//  RentoMovie
//
//  Created by Shailesh.Chandavar on 07/12/18.
//  Copyright © 2018 Shailesh.Chandavar. All rights reserved.
//

import Foundation


///APIURL enum contains all the app required URLs
enum APIURL: String {
    case movieListAPI = "http://api.themoviedb.org/3/search/movie?api_key=7e588fae3312be4835d4fcf73918a95f&query=a%20&page=**"
    
    //request construction
    func requestWithPage(page: Int) -> URLRequest? {
        guard let url = URL(string: rawValue.replacingOccurrences(of: "**", with: "\(page)")) else {return nil}
        return URLRequest(url: url)
    }
}

///Custom errors for RequestManager
enum RequestManagerError: LocalizedError {
    case noData
    
    var localizedDescription: String {
        var description = ""
        switch self{
        case .noData:
            description = "We are facing some technical issue, our team is working on it. Please try after sometime.".localized()
        }
        return description
    }
}

/// RequestManager handles the URL-request, error handling and Json serialization.
class RequestManager: NSObject {
    //Completion handler to send API response i.e. Dictionary and error if any.
    typealias responseCompletionHandler = ((NSDictionary?,Error?)->())
    var session: URLSession!
    private override init() {}
    
    ///Access RequestManager with requester method, this method is session configurable.
    class func requester(configuration: URLSessionConfiguration? = nil) -> RequestManager {
        let requester = RequestManager()
        let customSession = URLSession(configuration:  URLSessionConfiguration.default, delegate: requester, delegateQueue: nil)
        requester.session = customSession
        return requester
        
    }
    
    func getResponseForURL(urlRequest: URLRequest, completionHandler: responseCompletionHandler?) {
        session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            do {
                guard let `data` = data else { completionHandler?(nil, error != nil ? error : RequestManagerError.noData)
                    return
                }
                let response = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                completionHandler?(response, nil)
            } catch(let error) {
                completionHandler?(nil, error)
            }}.resume()
    }
    
}

//MARK: URLSession delegate
extension RequestManager: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
       
        
    }
}
