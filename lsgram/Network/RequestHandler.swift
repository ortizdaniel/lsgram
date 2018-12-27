//
//  RequestHandler.swift
//  lsgram
//
//  Created by Daniel on 26/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import SwiftyJSON

protocol RequestHandler {
    
    func reqParameters() -> [String: Any]
    
    func success(response: JSON)
    
    func error(message: String)
}
