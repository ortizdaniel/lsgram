//
//  UILabel+TextColor.swift
//  lsgram
//
//  Created by Carla Vendrell on 26/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func halfTextColorChange (fullText : String , changeText : String ) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 238.0 / 255.0, green: 88.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0) , range: range)
        self.attributedText = attribute
    }
    
}
