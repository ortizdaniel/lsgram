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
    
    func showHidePostButton() {
        if !theresInternet && navigationItem.rightBarButtonItems?.count == 2 {
            navigationItem.rightBarButtonItem = nil
            mvc?.navigationItem.rightBarButtonItem = nil
        } else if theresInternet && navigationItem.rightBarButtonItems?.count == 1 {
            navigationItem.rightBarButtonItems?.insert(btnPost, at: 0)
            mvc?.navigationItem.rightBarButtonItems?.insert((mvc?.btnPost)!, at: 0)
        }
    }
    
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
            followOnlySwitchChanged(0)
            print("Finished loading posts (\(posts.all().count))")
            if let mapView = (tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] as? MapViewController {
                if mapView.mapView != nil {
                    mapView.viewDidAppear(false)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            error(message: "There's no internet") //try to load from cache
        }
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.showHidePostButton()
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
        followOnlySwitchChanged(0)
        print("Finished loading posts from cache (\(posts.all().count))")
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.showHidePostButton()
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
}
