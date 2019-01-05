//
//  PostCellController.swift
//  lsgram
//
//  Created by Daniel on 27/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit
import ImageSlideshow
import SwiftyJSON
import AlamofireImage

class PostCellController: UITableViewCell, RequestHandler, FollowSubscriber {
    
    var post: PostItem? = nil
    @IBOutlet weak var lbPostTitle: UILabel!
    @IBOutlet weak var lbPostOwner: UILabel!
    @IBOutlet weak var lbPostDescription: UILabel!
    @IBOutlet weak var btnThumbsUp: UIButton!
    @IBOutlet weak var btnThumbsDown: UIButton!
    @IBOutlet weak var issPostImages: ImageSlideshow!
    @IBOutlet weak var lbPostLikes: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    var followSelected: Bool = false
    var parent: RecentPostsController!
    static var blueColor = UIColor(red: 49.0 / 255, green: 65.0 / 255, blue: 78.0 / 255, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnFollow.layer.cornerRadius = 8
    }
    
    func buildCell(post: PostItem) {
        //print("called (\(thumbsUpSelected))")
        self.post = post
        lbPostTitle.text = post.getTitle()
        lbPostOwner.text = post.getOwner()
        lbPostDescription.text = post.getCaption()
        lbPostLikes.text = "\(post.getLikes()) \(abs(post.getLikes()) == 1 ? "like" : "likes")"
        loadImages(links: post.getLinks())
        issPostImages.circular = false
        FollowingList.instance().subscribe(self)
        if FollowingList.instance().contains(post.getOwner()) {
            setHollowButton(btn: btnFollow)
            followSelected = true
        } else {
            setFilledButton(btn: btnFollow)
            followSelected = false
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostCellController.didTap))
        issPostImages.addGestureRecognizer(gestureRecognizer)
        if let user: String = UserDefaults.standard.object(forKey: "username") as? String, post.getOwner() == user {
            btnFollow.isHidden = true
        } else {
            btnFollow.isHidden = false
        }
        btnThumbsUp.setImage(
            UIImage(named: post.liked() ? "thumbs-up" : "thumbs-up-outline"),
            for: UIControl.State.normal
        )
        btnThumbsDown.setImage(
            UIImage(named: post.disliked() ? "thumbs-down" : "thumbs-down-outline"),
            for: UIControl.State.normal
        )
    }
    
    @objc func didTap() {
        issPostImages.presentFullScreenController(from: parent)
    }
    
    func notifyFollowChanged() {
        if FollowingList.instance().contains(post!.getOwner()) {
            setHollowButton(btn: btnFollow)
            followSelected = true
        } else {
            setFilledButton(btn: btnFollow)
            followSelected = false
        }
    }
    
    func setHollowButton(btn: UIButton) {
        DispatchQueue.main.async {
            btn.setTitle("  Unfollow  ", for: .normal)
            btn.layer.borderColor = PostCellController.blueColor.cgColor
            btn.backgroundColor = .clear
            btn.layer.borderWidth = 2
            btn.setTitleColor(PostCellController.blueColor, for: .normal)
        }
    }
    
    func setFilledButton(btn: UIButton) {
        DispatchQueue.main.async {
            btn.setTitle("  Follow  ", for: .normal)
            btn.backgroundColor = PostCellController.blueColor
            btn.layer.borderWidth = 0
            btn.setTitleColor(.white, for: .normal)
        }
    }
    
    func loadImages(links: [String]) {
        if links.count > 0 {
            var sources: [AlamofireSource] = []
            for l in links {
                if !l.isEmpty {
                    sources.append(AlamofireSource(urlString: l)!)
                }
            }
            issPostImages.setImageInputs(sources)
            issPostImages.contentScaleMode = .scaleAspectFill
        } else {
            issPostImages.setImageInputs([])
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func thumbsUpPressed(_ sender: Any) {
        if post!.disliked() {
            showAlert(title: "Can't do that!", message: "You can't like a post you disliked", buttonText: "Ok", whoPresents: parent, callback: nil)
        } else {
            post!.setLiked(b: !post!.liked())
            let handler = LikeHandler(post!.getId(), post!.liked(),
                                      btnThumbsUp, "thumbs-up", "thumbs-up-outline", lbPostLikes, post!)
            LSGram.likePost(handler: handler)
        }
    }
    
    @IBAction func thumbsDownPressed(_ sender: Any) {
        if post!.liked() {
            showAlert(title: "Can't do that!", message: "You can't dislike a post you liked", buttonText: "Ok", whoPresents: parent, callback: nil)
        } else {
            let handler = LikeHandler(post!.getId(), post!.disliked(),
                                      btnThumbsDown, "thumbs-down-outline", "thumbs-down", lbPostLikes, post!)
            LSGram.likePost(handler: handler)
            post!.setDisliked(b: !post!.disliked())
        }
    }
    
    @IBAction func followPressed(_ sender: UIButton) {
        followSelected = !followSelected
        LSGram.follow(handler: self)
    }
    
    func reqParameters() -> [String : Any] {
        let user = UserDefaults.standard.object(forKey: "username") as! String
        return ["who-follows": "\(user)",
                "who-following": "\(post!.getOwner())",
                "follow": "\(followSelected)"]
    }
    
    func success(response: JSON) {
        if response["status"].stringValue == "OK" {
            if response["message"].stringValue.contains("un") {
                followSelected = false
                self.setFilledButton(btn: self.btnFollow)
            } else {
                followSelected = true
                setHollowButton(btn: self.btnFollow)
            }
            LSGram.getFollowers(handler: FollowingRefresh())
        }
    }
    
    func error(message: String) {
        print("Error following/unfollowing user")
    }
}

class LikeHandler: RequestHandler {
    
    var id: Int
    var liked: Bool
    var button: UIButton
    var filled: String
    var outline: String
    var lbLikes: UILabel
    var post: PostItem
    
    init(_ id: Int, _ liked: Bool, _ button: UIButton, _ filled: String, _ outline: String, _ lbLikes: UILabel, _ post: PostItem) {
        self.id = id
        self.liked = liked
        self.button = button
        self.filled = filled
        self.outline = outline
        self.lbLikes = lbLikes
        self.post = post
    }
    
    func reqParameters() -> [String : Any] {
        return ["id": String(id),
                "like": String(liked)]
    }
    
    func success(response: JSON) {
        if (response["status"].stringValue == "OK") {
            DispatchQueue.main.async {
                UIView.transition(with: self.button as UIView, duration: 0.3, options: .transitionFlipFromRight, animations: {
                    self.button.setImage(UIImage(named: self.liked ? self.filled : self.outline), for: .normal)
                }, completion: nil)
                
                /*self.button.setImage(
                    UIImage(named: self.liked ? self.filled : self.outline),
                    for: UIControl.State.normal
                )*/
                let likes = response["data"]["likes"].intValue
                self.post.setLikes(l: likes)
                self.lbLikes.text = "\(likes) \(abs(likes) == 1 ? "like" : "likes")"
            }
        }
    }
    
    func error(message: String) {
        print("Could not give like/dislike to image id \(id)")
    }
}
