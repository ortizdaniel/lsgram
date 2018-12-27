//
//  Imgur.swift
//  
//
//  Created by Daniel on 27/12/2018.
//

import UIKit
import Alamofire

class Imgur {
    
    private static let CLIENT_ID: String = "6d55d3419fccf07"
    private static let UPLOAD_URL: URL = URL(string: "https://api.imgur.com/3/image")!
    
    static func uploadImage(image: UIImage, callback: @escaping (String?) -> Void) {
        let data = image.pngData()
        let base64 = data?.base64EncodedString()
        let params = ["image": base64]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            for (key, value) in params {
                multipartFormData.append((value?.data(using: .utf8))!, withName: key)
            }}, to: UPLOAD_URL, method: .post, headers: ["Authorization": "Client-ID " + CLIENT_ID],
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.response { response in
                            let json = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                            let imageDic = json?["data"] as? [String:Any]
                            callback(imageDic?["link"] as? String)
                        }
                    case .failure:
                        callback(nil)
                    }
        })
    }
}
