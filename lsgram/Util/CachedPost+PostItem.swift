//
//  CachedPost+PostItem.swift
//  lsgram
//
//  Created by Daniel on 27/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import CoreData

extension CachedPost: PostItem {
    
    func getId() -> Int {
        return Int(id)
    }
    
    func getTitle() -> String {
        return title ?? ""
    }
    
    func getCaption() -> String {
        return caption ?? ""
    }
    
    func getLikes() -> Int {
        return Int(likes)
    }
    
    func getLatitude() -> Double {
        return lat
    }
    
    func getLongitude() -> Double {
        return lng
    }
    
    func getOwner() -> String {
        return owner ?? ""
    }
    
    func getTakenAt() -> String {
        return takenAt ?? ""
    }
    
    func getLinks() -> [String] {
        var out: [String] = []
        if let str = links {
            let splitted = str.split(separator: "#")
            for link in splitted {
                out.append(String(link))
            }
        }
        return out
    }
}
