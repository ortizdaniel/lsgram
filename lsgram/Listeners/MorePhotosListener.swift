//
//  MorePhotosListener.swift
//  lsgram
//
//  Created by Carla Vendrell on 30/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit

protocol MorePhotosListener {
    func addMorePhotos(images: [UIImage])
    func removeAllPhotos()
}

