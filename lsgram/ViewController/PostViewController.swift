//
//  ViewController.swift
//  lsgram
//
//  Created by Daniel on 17/11/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    var post: PostItem? = nil
    var postsView: RecentPostsController? = nil
    @IBOutlet weak var lbOwner: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbLikes: UILabel!
    @IBOutlet weak var lbCaption: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnThumbsUp: UIButton!
    @IBOutlet weak var btnThumbsDown: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func buildView(post: PostItem) {
        self.post = post
    }
    
    @IBAction func followPressed(_ sender: Any) {
    }
    
    @IBAction func thumbsUpPressed(_ sender: Any) {
    }
    
    @IBAction func thumbsDownPressed(_ sender: Any) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let view = postsView {
            view.tableView.reloadData()
        }
    }
}

