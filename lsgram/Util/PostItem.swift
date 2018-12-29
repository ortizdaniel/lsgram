//
//  Post.swift
//  lsgram
//
//  Created by Daniel on 27/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit

protocol PostItem {
    
    func getId() -> Int
    
    func getTitle() -> String
    
    func getCaption() -> String
    
    func getLikes() -> Int
    
    func getLatitude() -> Double
    
    func getLongitude() -> Double
    
    func getOwner() -> String
    
    func getTakenAt() -> String
    
    func getLinks() -> [String]
    
    //current running instance only, not stored
    func setLiked(b: Bool)
    
    func setDisliked(b: Bool)
    
    func liked() -> Bool
    
    func disliked() -> Bool
    
    func setLikes(l: Int)
}
