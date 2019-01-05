//
//  ViewController.swift
//  lsgram
//
//  Created by Daniel on 17/11/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit
import ImageSlideshow
import SwiftyJSON
import AlamofireImage
import MapKit

class PostViewController: UIViewController, RequestHandler {

    var post: PostItem? = nil
    var postsView: RecentPostsController? = nil
    @IBOutlet weak var lbOwner: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbLikes: UILabel!
    @IBOutlet weak var lbCaption: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnThumbsUp: UIButton!
    @IBOutlet weak var btnThumbsDown: UIButton!
    @IBOutlet weak var issPostImages: ImageSlideshow!
    @IBOutlet weak var mapView: MKMapView!
    var followSelected: Bool = false
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewInsideStack: UIView!
    var theresInternet: Bool = false
    @IBOutlet weak var issPostImagesHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildView(post: post!)
        btnFollow.layer.cornerRadius = 8
    }

    func buildView(post: PostItem) {
        lbOwner.text = post.getOwner()
        lbTitle.text = post.getTitle()
        lbLikes.text = "\(post.getLikes()) \(abs(post.getLikes()) == 1 ? "like" : "likes")"
        lbCaption.text = post.getCaption()
        loadImages(links: post.getLinks())
        issPostImages.circular = false
        if FollowingList.instance().contains(post.getOwner()) {
            setHollowButton(btn: btnFollow)
            followSelected = true
        } else {
            setFilledButton(btn: btnFollow)
            followSelected = false
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostViewController.didTap))
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
        
        let annotation = MKPointAnnotation()
        let coord = CLLocationCoordinate2D(latitude: post.getLatitude(),
                                           longitude: post.getLongitude())
        annotation.coordinate = coord
        annotation.title = post.getTitle()
        var region = MKCoordinateRegion()
        region.center = coord
        region.span.latitudeDelta = 0.1
        region.span.longitudeDelta = 0.1
        
        mapView.setRegion(region, animated: false)
        mapView.addAnnotation(annotation)
        
        if !theresInternet {
            stackView.setView([viewInsideStack], gone: true, animated: false)
            btnFollow.isHidden = true
            btnThumbsUp.isHidden = true
            btnThumbsDown.isHidden = true
            issPostImagesHeight.constant = 0
        }
    }
    
    @objc func didTap() {
        issPostImages.presentFullScreenController(from: self)
    }
    
    func loadImages(links: [String]) {
        if links.count > 0 {
            var sources: [AlamofireSource] = []
            for l in links {
                sources.append(AlamofireSource(urlString: l)!)
            }
            issPostImages.setImageInputs(sources)
            issPostImages.contentScaleMode = .scaleAspectFill
        } else {
            issPostImages.setImageInputs([])
        }
    }
    
    @IBAction func followPressed(_ sender: Any) {
        followSelected = !followSelected
        LSGram.follow(handler: self)
    }
    
    @IBAction func thumbsUpPressed(_ sender: Any) {
        if post!.disliked() {
            showAlert(title: "oops".localize(), message: "oops_dislike".localize(), buttonText: "OK", callback: nil)
        } else {
            post!.setLiked(b: !post!.liked())
            let handler = LikeHandler(post!.getId(), post!.liked(),
                                      btnThumbsUp, "thumbs-up", "thumbs-up-outline", lbLikes, post!)
            LSGram.likePost(handler: handler)
        }
    }
    
    @IBAction func thumbsDownPressed(_ sender: Any) {
        if post!.liked() {
            showAlert(title: "oops".localize(), message: "oops_like".localize(), buttonText: "OK", callback: nil)
        } else {
            let handler = LikeHandler(post!.getId(), post!.disliked(),
                                      btnThumbsDown, "thumbs-down-outline", "thumbs-down", lbLikes, post!)
            LSGram.likePost(handler: handler)
            post!.setDisliked(b: !post!.disliked())
        }
    }
    
    func setHollowButton(btn: UIButton) {
        DispatchQueue.main.async {
            btn.setTitle("unfollow".localize(), for: .normal)
            btn.layer.borderColor = PostCellController.blueColor.cgColor
            btn.backgroundColor = .clear
            btn.layer.borderWidth = 2
            btn.setTitleColor(PostCellController.blueColor, for: .normal)
        }
    }
    
    func setFilledButton(btn: UIButton) {
        DispatchQueue.main.async {
            btn.setTitle("follow".localize(), for: .normal)
            btn.backgroundColor = PostCellController.blueColor
            btn.layer.borderWidth = 0
            btn.setTitleColor(.white, for: .normal)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let view = postsView {
            view.tableView.reloadData()
        }
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
        print("error_follow".localize())
    }
}

