import Foundation
import Parse
import Bond

// 1
class Post : PFObject, PFSubclassing {
    
    var photoUploadTask: UIBackgroundTaskIdentifier?
        //adds the photo upload task property
    
    var image: Dynamic <UIImage?> = Dynamic(nil)
    
    var likes =  Dynamic<[PFUser]?>(nil)
    
    // 2
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    
    //MARK: PFSubclassing Protocol
    
    func uploadPost(){
        let imageData = UIImageJPEGRepresentation(image.value, 0.8)
        //turns UIImage into NSData instance because PFFile class needs NSData instance
        let imageFile = PFFile(data: imageData)
        
        photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)}
        
        
        imageFile.saveInBackgroundWithBlock { (success: Bool, Error: NSError?) -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)}
        //creates and uploads the file
        
        // any uploaded post should be associated with the current user
        user = PFUser.currentUser()
     
        self.imageFile = imageFile
        saveInBackgroundWithBlock(nil)
        //assigns imagefile to the post and saves to parse as well then stores it
    }
    
    
    
    
    // 3
    static func parseClassName() -> String {
        return "Post"
    }
    
    // 4
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    func downloadImage() {
        // if image is not downloaded yet, get it
        // 1
        if (image.value == nil) {
            // 2
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    // 3
                    self.image.value = image
                }
            }
        }
    }
    
    func fetchLikes() {
        // 1
        if (likes.value != nil) {
            return
        }
        
        // 2
        ParseHelper.likesForPost(self, completionBlock: { (var likes: [AnyObject]?, error: NSError?) -> Void in
            // 3
            likes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            // 4
            self.likes.value = likes?.map { like in
                let like = like as! PFObject
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return contains(likes, user)
        } else {
            return false
        }
    }
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // if image is liked, unlike it now
            // 1
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post: self)
        } else {
            // if this image is not liked yet, like it now
            // 2
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }

    
}

//1. To create a custom Parse class you need to inherit from PFObject and implement the PFSubclassing protocol
//2. Next, define each property that you want to access on this Parse class. For our Post class that's the user and the imageFile of a post. That will allow you to change the code that accesses properties through strings: post["imageFile"] = imageFile Into code that uses Swift properties: post.imageFile = imageFile
//3. By implementing the parseClassName you create a connection between the Parse class and your Swift class.
//4. init and initialize are pure boilerplate code - copy these two into any custom Parse class that you're creating.
