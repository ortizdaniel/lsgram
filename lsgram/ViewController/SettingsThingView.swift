//
//  SettingsThingView.swift
//  lsgram
//
//  Created by Daniel on 02/01/2019.
//  Copyright © 2019 Daniel. All rights reserved.
//

import UIKit

class SettingsThingView: UIView {
    
    var mapView: MapViewController? = nil
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if let view = mapView {
            view.tfMinVotes.text = view.rpc?.tfMinVotes.text ?? ""
            view.switchFollowing.setOn(view.rpc?.switchFollowing?.isOn ?? false, animated: true)
        }
    }
}
