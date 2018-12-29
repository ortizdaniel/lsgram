//
//  MKPointAnnotation+PostItem.swift
//  lsgram
//
//  Created by Daniel on 29/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit
import MapKit

class PostMapPoint: MKPointAnnotation {
    
    var post: PostItem
    
    init(post: PostItem) {
        self.post = post
    }
}
