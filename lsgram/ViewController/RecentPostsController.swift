//
//  RecentPostsController.swift
//  lsgram
//
//  Created by Daniel on 27/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

class RecentPostsController: UIViewController, UITableViewDelegate, UITableViewDataSource, RequestHandler, UITextFieldDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    var button: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsStack: UIStackView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var tfMinVotes: UITextField!
    @IBOutlet weak var switchFollowing: UISwitch!
    
    var theresInternet: Bool = false
    var settingsToggled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createFloatingButton()
        
        LSGram.getFollowers(handler: FollowingRefresh())
        LSGram.getPosts(handler: self)
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        settingsStack.setView([settingsView], gone: true, animated: false)
        settingsView.addBottomBorderWithColor(color: .lightGray, width: 1)
        tfMinVotes!.keyboardType = .numberPad
        tfMinVotes!.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostList.instance().filtered().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        if theresInternet {
            let finalCell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostCellController
            finalCell.buildCell(post: PostList.instance().filtered()[indexPath.row])
            finalCell.parent = self
            cell = finalCell
        } else {
            let finalCell = tableView.dequeueReusableCell(withIdentifier: "noInternetCell") as! NoInternetCellController
            finalCell.buildCell(post: PostList.instance().filtered()[indexPath.row])
            cell = finalCell
        }
        
        return cell
    }

    @objc func refresh(_ sender: AnyObject) {
        LSGram.getPosts(handler: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        performSegue(withIdentifier: "postDetailFromList",
                     sender: PostList.instance().filtered()[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postDetailFromList",
            let dest = segue.destination as? PostViewController,
            let post = sender as? PostItem {
            dest.post = post
            dest.postsView = self
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        settingsStack.setView([settingsView], gone: settingsToggled, animated: true)
        settingsToggled = !settingsToggled
    }
    
    @IBAction func followOnlySwitchChanged(_ sender: Any) {
        DispatchQueue.main.async {
            let isOn: Bool = self.switchFollowing.isOn
                if self.tfMinVotes!.text?.isEmpty ?? false {
                    if isOn {
                        PostList.instance().filterFollowing(
                            following: FollowingList.instance().following()
                        )
                    } else {
                        PostList.instance().noFilter()
                    }
                } else {
                    let minVotes: Int = Int(self.tfMinVotes.text!)!
                    if isOn {
                        PostList.instance().filterFollowingAndMinLikes(
                            following: FollowingList.instance().following(),
                            amount: minVotes
                        )
                    } else {
                        PostList.instance().filterMinLikes(amount: minVotes)
                    }
                }
                //print(PostList.instance().filtered())
            self.tableView!.reloadData()
        }
    }
    
    @IBAction func minVotesChanged(_ sender: Any) {
        followOnlySwitchChanged(sender)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey: "username")
        prefs.removeObject(forKey: "password")
        prefs.synchronize()
        PostList.instance().clearAll()
        FollowingList.instance().removeAll()
        clearCache()
        
        performSegue(withIdentifier: "logout", sender: sender)
    }
    
    @objc func addNewPost() {
        performSegue(withIdentifier: "newpost", sender: self)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        button.isHidden = false
        button.isEnabled = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        button.isHidden = true
        button.isEnabled = false
    }
}
