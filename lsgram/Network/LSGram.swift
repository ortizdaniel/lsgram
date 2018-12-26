//
//  LSGram.swift
//  lsgram
//
//  Created by Daniel on 26/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import Foundation

class LSGram {
    
    private static let BASE_URL: String = "http://puigpedros.salleurl.edu/lsgram/"
    private static let REGISTER: String = "register"
    private static let LOGIN: String = "login"
    private static let POST: String = "post"
    private static let LIKE_UNLIKE: String = "like"
    private static let FOLLOW: String = "follow"
    private static let FOLLOWING: String = "following"
    private static let GET_POSTS: String = "allposts"
    
    private static func performRequest(method: String, url: String, handler: RequestHandler) {
        let url = URL(string: url)!
        var req: URLRequest = URLRequest(url: url)
        req.httpMethod = method
        
        if method != "GET" {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                req.httpBody = try JSONSerialization.data(withJSONObject: handler.reqParameters())
                //print(NSString(data: req.httpBody!, encoding:String.Encoding.utf8.rawValue)!)
            } catch {
                handler.error(message: "Could not serialize the request parameters.")
                return
            }
        }
        
        URLSession.shared.dataTask(with: req) {
            (data, response, error) in
            do {
                let response = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                handler.success(response: response!)
            } catch {
                handler.error(message: "Could not perform the the call correctly.")
            }
        }.resume()
    }
    
    static func register(handler: RequestHandler) {
        performRequest(method: "POST", url: BASE_URL + REGISTER, handler: handler)
    }
    
    static func login(handler: RequestHandler) {
        performRequest(method: "POST", url: BASE_URL + LOGIN, handler: handler)
    }
    
    static func getPosts(handler: RequestHandler) {
        performRequest(method: "GET", url: BASE_URL + GET_POSTS, handler: handler)
    }
}
