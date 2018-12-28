//
//  FollowingRefresh.swift
//  lsgram
//
//  Created by Daniel on 28/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit
import SwiftyJSON

class FollowingRefresh: RequestHandler {
    
    func reqParameters() -> [String : Any] {
        let prefs = UserDefaults.standard
        return ["username": prefs.object(forKey: "username") as! String,
                "password": prefs.object(forKey: "password") as! String
        ]
    }
    
    func success(response: JSON) {
        if response["status"] == "OK" {
            for subJson in response["data"].arrayValue {
                FollowingList.instance().add(user: subJson["userId"].stringValue)
            }
            print("Followers obtained successfully")
        }
    }
    
    func error(message: String) {
        print("Couldn't get followers")
    }
}
