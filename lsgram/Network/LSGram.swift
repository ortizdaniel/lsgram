//
//  LSGram.swift
//  lsgram
//
//  Created by Daniel on 26/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import SwiftyJSON

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
                //print(String(data: req.httpBody!, encoding: String.Encoding.utf8))
            } catch {
                handler.error(message: "error_json_serialize".localize())
                return
            }
        }
        
        URLSession.shared.dataTask(with: req) {
            (data, response, error) in
            do {
                if let json = data {
                    //let out = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                    handler.success(response: try JSON(data: json))
                } else if error != nil {
                    handler.error(message: error!.localizedDescription)
                }
            } catch {
                handler.error(message: "error_json_parse".localize())
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
    
    static func likePost(handler: RequestHandler) {
        performRequest(method: "POST", url: BASE_URL + LIKE_UNLIKE, handler: handler)
    }
    
    static func getFollowers(handler: RequestHandler) {
        performRequest(method: "POST", url: BASE_URL + FOLLOWING, handler: handler)
    }
    
    static func post(handler: RequestHandler) {
        performRequest(method: "POST", url: BASE_URL + POST, handler: handler)
    }
    
    static func follow(handler: RequestHandler) {
        performRequest(method: "POST", url: BASE_URL + FOLLOW, handler: handler)
    }
}
