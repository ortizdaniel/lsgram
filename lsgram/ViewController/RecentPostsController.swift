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
    
    var button: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostList.instance().filtered().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostCellController
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createFloatingButton()
        
        LSGram.getPosts(handler: self)
    }
    
    
    func reqParameters() -> [String : Any] {
        return [:]
    }
    
    func success(response: JSON) {
        //load posts from API
        if response["status"] == "OK" {
            let posts = PostList.instance()
            for jsonPost in response["data"].arrayValue {
                posts.add(PostJSON(json: jsonPost))
            }
            posts.noFilter()
            print("Finished loading posts")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func error(message: String) {
        //load posts from DB cache
        print(message)
        let posts: PostList = PostList.instance()
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "CachedPost")
        posts.addAll(try! context.fetch(fetch) as! [PostItem])
        posts.noFilter()
        print("Finished loading posts from cache")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey: "username")
        prefs.synchronize()
        
        performSegue(withIdentifier: "logout", sender: sender)
    }
    
    private func createFloatingButton() {
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
