//
//  NoInternetCellController.swift
//  lsgram
//
//  Created by Daniel on 28/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit

class NoInternetCellController: UITableViewCell {

    @IBOutlet weak var lbPostOwner: UILabel!
    @IBOutlet weak var lbPostTitle: UILabel!
    @IBOutlet weak var lbPostDescription: UILabel!
    @IBOutlet weak var lbPostLikes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func buildCell(post: PostItem) {
        lbPostOwner.text = post.getOwner()
        lbPostTitle.text = post.getTitle()
        lbPostDescription.text = post.getCaption()
        lbPostLikes.text = "\(post.getLikes()) likes"
    }
}
