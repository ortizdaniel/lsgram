//
//  FollowingList.swift
//  lsgram
//
//  Created by Daniel on 28/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

class FollowingList {
    
    private static var inst: FollowingList? = nil
    
    private var list: [String]
    private var subscribers: [FollowSubscriber]
    
    private init() {
        self.list = []
        self.subscribers = []
    }
    
    static func instance() -> FollowingList {
        if (inst == nil) {
            inst = FollowingList()
        }
        return inst!
    }
    
    func contains(_ user: String) -> Bool {
        return list.contains(user)
    }
    
    func removeAll() {
        list.removeAll()
        notifyAll()
    }
    
    func add(user: String) {
        if !list.contains(user) {
            list.append(user)
        }
        notifyAll()
    }
    
    func remove(user: String) {
        if list.contains(user) {
            list.remove(at: list.firstIndex(of: user)!)
        }
        notifyAll()
    }
    
    func subscribe(_ who: FollowSubscriber) {
        subscribers.append(who)
    }
    
    func following() -> [String] {
        //DO NOT ATTEMPT UNDER ANY CIRCUMSTANCE TO USE THIS LIST AFTER
        //GETTING IT FROM THIS FUNCTION, USE IT ONLY FOR READING NOT WRITING
        return list
    }
    
    private func notifyAll() {
        for sub in subscribers {
            sub.notifyFollowChanged()
        }
    }
}
