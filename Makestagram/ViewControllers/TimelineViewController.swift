//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Samuel Coby Anderson on 6/29/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit


class TimelineViewController: UIViewController, TimelineComponentTarget {
    
    @IBOutlet weak var tableView: UITableView!
    
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!
    
    let defaultRange = 0...4
    let additionalRangeSize = 5
        //properties of the timeline posts
    
   
    
    var photoTakingHelper: PhotoTakingHelper?

    override func viewDidLoad() {
        super.viewDidLoad()
        timelineComponent = TimelineComponent(target: self)
            //initializes a timeline component
        self.tabBarController?.delegate = self
            //sets the TimelineViewController as the delegate of the TabBarController

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        //loads posts
        // 1
        ParseHelper.timelineRequestforCurrentUser(range) {
            (result: [AnyObject]?, error: NSError?) -> Void in
            // 2
            let posts = result as? [Post] ?? []
            // 3
            completionBlock(posts)
        }
    }
    
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo  is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
            let post = Post()
            post.image.value = image!
            post.uploadPost()

        }
    
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        timelineComponent.loadInitialIfRequired()
        }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension TimelineViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            takePhoto()
            return false
        }
        else {
            return true
        }
    }
}

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1
        return timelineComponent.content.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 2
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCells
        
        let post = timelineComponent.content[indexPath.row]
        post.downloadImage()
        post.fetchLikes()
        cell.post = post
        return cell
        
    }
}
extension TimelineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    }
    
}
