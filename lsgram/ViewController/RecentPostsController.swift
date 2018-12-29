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

class RecentPostsController: UIViewController, UITableViewDelegate, UITableViewDataSource, RequestHandler {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    var button: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsStack: UIStackView!
    @IBOutlet weak var settingsView: UIView!
    
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
        //TODO performSegue to post information
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        settingsStack.setView([settingsView], gone: settingsToggled, animated: true)
        settingsToggled = !settingsToggled
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey: "username")
        prefs.synchronize()
        
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
