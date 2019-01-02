//
//  String+Localize.swift
//  lsgram
//
//  Created by Carla Vendrell on 02/01/2019.
//  Copyright © 2019 Daniel. All rights reserved.
//

import Foundation

extension String {
    
    func localize() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
}
