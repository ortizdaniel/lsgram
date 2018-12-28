//
//  PostsList.swift
//  lsgram
//
//  Created by Daniel on 27/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

class PostList {
    
    private static var inst: PostList? = nil
    
    private var allPosts: [PostItem]
    private var filteredPosts: [PostItem]
    
    private init() {
        self.allPosts = []
        self.filteredPosts = []
    }
    
    static func instance() -> PostList {
        if (inst == nil) {
            inst = PostList()
        }
        return inst!
    }
    
    func all() -> [PostItem] {
        return allPosts
    }
    
    func filtered() -> [PostItem] {
        return filteredPosts
    }
    
    //should only be used when populating the allPosts list
    func add(_ item: PostItem) {
        allPosts.append(item)
    }
    
    func addAll(_ items: [PostItem]) {
        allPosts.append(contentsOf: items)
    }
    
    func noFilter() {
        filteredPosts.removeAll()
        filteredPosts.append(contentsOf: allPosts)
        sort()
    }
    
    func filterFollowing(following: [String]) {
        filteredPosts.removeAll()
        for post in allPosts {
            if following.contains(post.getOwner()) {
                filteredPosts.append(post)
            }
        }
        sort()
    }
    
    func filterMinLikes(amount: Int) {
        filteredPosts.removeAll()
        for post in allPosts {
            if post.getLikes() >= amount {
                filteredPosts.append(post)
            }
        }
        sort()
    }
    
    func filterFollowingAndMinLikes(following: [String], amount: Int) {
        filterFollowing(following: following)
        for (i, post) in filteredPosts.enumerated() {
            if post.getLikes() < amount {
                filteredPosts.remove(at: i)
            }
        }
        sort()
    }
    
    func sort() {
        allPosts.sort {
            a, b in
            return a.getTakenAt().compare(b.getTakenAt()) == .orderedAscending
        }
        filteredPosts.sort {
            a, b in
            return a.getTakenAt().compare(b.getTakenAt()) == .orderedAscending
        }
    }
}
