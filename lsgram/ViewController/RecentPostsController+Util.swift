//
//  RecentPostsController+Settings.swift
//  lsgram
//
//  Created by Daniel on 29/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

extension RecentPostsController {
    
    func reqParameters() -> [String : Any] {
        return [:]
    }
    
    func success(response: JSON) {
        PostList.instance().clearAll()
        //load posts from API and cache them instantly
        if response["status"] == "OK" {
            theresInternet = true
            clearCache()
            
            let posts = PostList.instance()
            for jsonPost in response["data"].arrayValue {
                let post: PostItem = PostJSON(json: jsonPost)
                posts.add(post)
                
                //start adding them to DB
                if !addToCache(post: post) {
                    print("Error adding post to cache")
                }
            }
            try? context.save()
            posts.noFilter()
            print("Finished loading posts (\(posts.all().count))")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            error(message: "There's no internet") //try to load from cache
        }
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    func error(message: String) {
        PostList.instance().clearAll()
        theresInternet = false
        //load posts from DB cache
        print(message)
        let posts: PostList = PostList.instance()
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "CachedPost")
        posts.addAll(try! context.fetch(fetch) as! [PostItem])
        posts.noFilter()
        print("Finished loading posts from cache (\(posts.all().count))")
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func addToCache(post: PostItem) -> Bool {
        if let entity = NSEntityDescription.entity(forEntityName: "CachedPost", in: context) {
            let cachedPost = NSManagedObject(entity: entity, insertInto: context)
            cachedPost.setValue(post.getId(), forKey: "id")
            cachedPost.setValue(post.getTitle(), forKey: "title")
            cachedPost.setValue(post.getCaption(), forKey: "caption")
            cachedPost.setValue(post.getLikes(), forKey: "likes")
            cachedPost.setValue(post.getLatitude(), forKey: "lat")
            cachedPost.setValue(post.getLongitude(), forKey: "lng")
            cachedPost.setValue(post.getOwner(), forKey: "owner")
            cachedPost.setValue(post.getTakenAt(), forKey: "takenAt")
            var links: String = ""
            let linkArray: [String] = post.getLinks()
            for i in stride(from: 0, to: linkArray.count - 1, by: 1) {
                links += "\(linkArray[i])#"
            }
            //because some people post images without a link
            if linkArray.count > 0 {
                links += "\(linkArray[linkArray.count - 1])"
            }
            cachedPost.setValue(links, forKey: "links")
            return true
        } else {
            return false
        }
    }
    
    func clearCache() {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedPost")
        let deleteReq = NSBatchDeleteRequest(fetchRequest: req)
        do {
            try context.execute(deleteReq)
            try context.save()
        } catch _ {
            print("Error deleting the cache")
        }
    }
    
    func createFloatingButton() {
        let buttonSize = 48
        let buttonX = self.view.frame.width - 70
        let buttonY = self.view.frame.height - 70 - (self.tabBarController?.tabBar.frame.height)!
        
        button = UIButton(frame: CGRect(origin: CGPoint(x: buttonX, y: buttonY), size: CGSize(width: buttonSize, height: buttonSize)))
        button.backgroundColor = UIColor(red: 238.0 / 255.0, green: 88.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0)
        button.layer.cornerRadius = CGFloat(buttonSize / 2)
        button.setImage(UIImage(named: "plus-icon-white") as UIImage?, for: .normal)
        button.addTarget(self, action: #selector(addNewPost), for: .touchUpInside)
        
        self.navigationController?.view.addSubview(button)
    }
}
