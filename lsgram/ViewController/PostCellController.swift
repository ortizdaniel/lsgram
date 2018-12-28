//
//  PostCellController.swift
//  lsgram
//
//  Created by Daniel on 27/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit
import ImageSlideshow
import Alamofire
import AlamofireImage

class PostCellController: UITableViewCell {
    
    var post: PostItem? = nil
    @IBOutlet weak var lbPostTitle: UILabel!
    @IBOutlet weak var lbPostOwner: UILabel!
    @IBOutlet weak var lbPostDescription: UILabel!
    @IBOutlet weak var btnThumbsUp: UIButton!
    @IBOutlet weak var btnThumbsDown: UIButton!
    @IBOutlet weak var issPostImages: ImageSlideshow!
    @IBOutlet weak var lbPostLikes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func buildCell(post: PostItem) {
        self.post = post
        lbPostTitle.text = post.getTitle()
        lbPostOwner.text = post.getOwner()
        lbPostDescription.text = post.getCaption()
        lbPostLikes.text = "\(post.getLikes()) likes"
        loadImages(links: post.getLinks())
        issPostImages.circular = false
    }
    
    func loadImages(links: [String]) {
        if links.count > 0 {
            var sources: [AlamofireSource] = []
            for l in links {
                sources.append(AlamofireSource(urlString: l)!)
            }
            issPostImages.setImageInputs(sources)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
