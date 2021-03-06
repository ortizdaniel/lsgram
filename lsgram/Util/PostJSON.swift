//
//  PostJSON.swift
//  lsgram
//
//  Created by Daniel on 27/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//
import UIKit
import SwiftyJSON

class PostJSON: PostItem {
    
    private var lk: Bool = false
    private var dlk: Bool = false
    
    private var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    func getId() -> Int {
        return json["id"].intValue
    }
    
    func getTitle() -> String {
        return json["title"].stringValue
    }
    
    func getCaption() -> String {
        return json["caption"].stringValue
    }
    
    func getLikes() -> Int {
        return json["likes"].intValue
    }
    
    func getLatitude() -> Double {
        return json["lat"].doubleValue
    }
    
    func getLongitude() -> Double {
        return json["lng"].doubleValue
    }
    
    func getOwner() -> String {
        return json["owner"].stringValue
    }
    
    func getTakenAt() -> String {
        return json["takenAt"].stringValue
    }
    
    func getLinks() -> [String] {
        var links: [String] = []
        for (_, subJson) in json["links"] {
            links.append(subJson["link"].stringValue)
        }
        return links
    }
    
    func setLiked(b: Bool) {
        lk = b
    }
    
    func setDisliked(b: Bool) {
        dlk = b
    }
    
    func liked() -> Bool {
        return lk
    }
    
    func disliked() -> Bool {
        return dlk
    }
    
    func setLikes(l: Int) {
        json["likes"] = JSON(l)
    }
}
