//
//  UserModel.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/11/27.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage


class DataModel{
    private var users = [User]() // array to store all of the users
    private var locations = [Location]() // array to store all of the locations
    private var UserLoctionRelation = [Location: [[User: String]]]() // map (essentially an ajacency list) to store relation of location and user
    private var likeLocation = [[User: Location]]()
    
    static let sharedInstance = DataModel() // Singleton
    private var userFilepath: String
    private var locationFilepath: String
    private var relationFilepath: String
    private var likeFilepath: String
    
    var currentUser : User? // no user has logged in --> no current user
    var currentLocation: Location?
    
    // firebase database
    var ref: DatabaseReference?
    var databaseHandler: DatabaseHandle?
    
    // filemanager
    let manager: FileManager
    
    // keys in the User
    let kUsersPlist = "Users.plist"
    let kUsernameKey = "Username"
    let kUserEmailKey = "UserEmail"
    let kUserNumPost = "numPost"
    let kUsernumLikes = "numLikes"
    
    // keys in the Location
    let kLocationPlist = "Locations.plist"
    let kLocationImageDirectory = "LocationImages"
    let kLocationNameKey = "name"
    let kLocationLatiKey = "latitude"
    let kLocationLongKey = "longitude"
    let kLocationNumLikeKey = "numLike"
    
    // keys in the Relation
    let kRelationPlist = "Relation.plist"
    let kRelationLocCoorKey = "LocationCoor"
    let kRelationUserEmail = "userEmail"
    let kRelationUserComment = "userComment"

    // keys in the Like.plist [[String: String]]
    let kLikeLocationPlist = "Like.plist"
    let kLikeUser = "user"
    let kLikeLocation = "location"
    
    // firebase storage variables
    let storage = Storage.storage()
    let storageRef: StorageReference
    init() {
        // initialize variables
        manager = FileManager.default
        let urlUser = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let urlLocation = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let urlRelation = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let urlLike = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        userFilepath = urlUser!.appendingPathComponent(kUsersPlist).path
        locationFilepath = urlLocation!.appendingPathComponent(kLocationPlist).path
        relationFilepath = urlRelation!.appendingPathComponent(kRelationPlist).path
        likeFilepath = urlLike!.appendingPathComponent(kLikeLocationPlist).path
        
        // initialize database stuff
        ref = Database.database().reference()
       
        // Create a root reference
        storageRef = storage.reference()
        
        // loadData from database
         createMockData() // for testing putporse
        loadData()
    }
    
    func loadData() {
        databaseHandler = ref?.child("User").observe(.value) { (snapshots) in
            // call back function
            if snapshots.exists() {
                self.loadUserFromDB(snapshots)
            }
        }
        
        databaseHandler = ref?.child("Location").observe(.value) { (snapshots) in
            // call back function
            if snapshots.exists() {
                self.loadLocationFromDB(snapshots)
            }
        }
        
        databaseHandler = ref?.child("Relation").observe(.value) { (snapshots) in
            // call back function
            if snapshots.exists() {
                self.loadRelationFromDB(snapshots)
            }
        }
        
        databaseHandler = ref?.child("Like").observe(.value) { (snapshots) in
            // call back function
            if snapshots.exists() {
                self.loadLikeFromDB(snapshots)
            }
        }
    }
    
    func loadUserFromDB(_ snapshots: DataSnapshot) {
        users = [User]()
        // read in users
        let usersArray = snapshots.value as! NSArray?
        if let usersA = usersArray {
            for dic in usersA {
                let userDic = dic as! [String: String]
                let newUser = User(name: userDic[kUsernameKey]!, email: userDic[kUserEmailKey]!, numPost: Int(userDic[kUserNumPost]!) ?? 0 , numLikes: Int(userDic[kUsernumLikes]!) ?? 0)
                users.append(newUser)
            }
        }
    }
    
    func loadLocationFromDB(_ snapshots: DataSnapshot) {
        locations = [Location]()
        
        let locationsArray = snapshots.value as! NSArray?
        // make sure that the data is able to be put into an NSArray
        if let locationsA = locationsArray {
            for dic in locationsA {
                // get non-image information from the plist
                let locationDic = dic as! [String: String]
                let locationName = locationDic[kLocationNameKey]!
                let locationLati = Double(locationDic[kLocationLatiKey]!) ?? 0.0
                let locationLong = Double(locationDic[kLocationLongKey]!) ?? 0.0
                let locationNumLike = Int(locationDic[kLocationNumLikeKey]!) ?? 0
                
                let newLocation = Location(name: locationName, latitude: locationLati, longitude: locationLong, numLike: locationNumLike)
                locations.append(newLocation)
            }
        }
    }
    
    func loadRelationFromDB(_ snapshots: DataSnapshot) {
        UserLoctionRelation = [Location: [[User: String]]]()
        
        // initialize a spot for each of the location read in
        for location in locations {
            UserLoctionRelation[location] = [[User: String]]()
        }
        
        let relationArray = snapshots.value as! NSArray?
        // make sure that the data is able to be put into an NSDictionary
        if let relationArrayA = relationArray {
            for dic in relationArrayA {
                // get data from the array
                let relationDic = dic as! [String: String]
                let coordinate = relationDic[kRelationLocCoorKey]!
                let userEmail = relationDic[kRelationUserEmail]!
                let userComment = relationDic[kRelationUserComment]!
                
                // find the location and user in terms of the coordinate and email from user and location array
                if let foundLocation = findLocation(coordinate: coordinate), let user = findUser(email: userEmail) {
                    // newLoc = foundLocation
                    UserLoctionRelation[foundLocation]?.append([user: userComment])
                }
            }
        }
    }
    
    func loadLikeFromDB(_ snapshots: DataSnapshot) {
        likeLocation = [[User: Location]]()
        // read in like relation
        let likeArray = snapshots.value as! NSArray?
        if let likeArrayA = likeArray {
            for dic in likeArrayA {
                let likeDic = dic as! [String: String]
                let userEmail = likeDic[kLikeUser]
                let locCoor = likeDic[kLikeLocation]
                
                let user = findUser(email: userEmail!)
                let loc = findLocation(coordinate: locCoor!)
                
                if let user = user, let loc = loc {
                    likeLocation.append([user: loc])
                }
            }
        }
    }
    
    func createMockData() {
        // create user mock data
        let user1 = User(name: "Yulun Zhang", email: "yulunzha@usc.edu")
        let user2 = User(name: "Peter", email: "peter@gmail.com")
        let user3 = User(name: "Jude", email: "jude@gmail.com")
        let user4 = User(name: "David", email: "david@gmail.com")
        users = [user1, user2, user3, user4]
        
        // create location mock data
        let location1 = Location(name: "location1", latitude: 34.0522, longitude: -118.2437, numLike: 4)
        let location2 = Location(name: "location2", latitude: 33.0522, longitude: -118.2437, numLike: 0)
        let location3 = Location(name: "location3", latitude: 33.0522, longitude: -117.2437, numLike: 2)
        let location4 = Location(name: "location4", latitude: 34.0522, longitude: -117.2437, numLike: 1)
        locations = [location1, location2, location3, location4]
        
        // create relation mock data
        UserLoctionRelation[location1] = [[User: String]]()
        UserLoctionRelation[location1]?.append([user1: "I like here"])
        UserLoctionRelation[location1]?.append([user1: "I like here again!"])
        UserLoctionRelation[location1]?.append([user2: "Awsome place!"])
        UserLoctionRelation[location1]?.append([user3: "Nice place for travelling"])
        
        UserLoctionRelation[location3] = [[User: String]]()
        UserLoctionRelation[location3]?.append([user2: "I love to be there"])
        UserLoctionRelation[location3]?.append([user3: "here"])
        
        UserLoctionRelation[location4] = [[User: String]]()
        UserLoctionRelation[location4]?.append([user1: "going with my parents, nice place"])
        
        // create like mock data
        likeLocation.append([user1: location1])
        likeLocation.append([user2: location1])
        likeLocation.append([user3: location1])
        likeLocation.append([user4: location1])
        
        user1.setNumLikes(numLikes: 1)
        user2.setNumLikes(numLikes: 1)
        user3.setNumLikes(numLikes: 1)
        user4.setNumLikes(numLikes: 1)
        
        // for testing purpose
        saveUsers()
        saveLocations()
        saveRelation()
        saveLike()
    }
    
    func getUsers() -> [User]{
        return users
    }
    
    func getLocations() -> [Location] {
        return locations
    }
    
    func getRelations() -> [Location: [[User: String]]] {
        return UserLoctionRelation
    }
    
    func getLike() -> [[User: Location]] {
        return likeLocation
    }
    
    // function to get the current user
    func setCurrentUser(email: String){
        // find the user with the current email
        for user in users{
            if user.getEmail() == email {
                currentUser = user
                print("current user is now the one with email \(email)")
                return
            }
        }
    }
    
    // add user
    func addUser (newUser: User) {
        users.append(newUser)
        print("user \(newUser.getName()) added")
        saveUsers()
    }
    
    // add location
    func addLocation (newLocation: Location) {
        locations.append(newLocation)
        UserLoctionRelation[newLocation] = [[User: String]]()
        print("location \(newLocation.getName()) added")
        saveLocations()
    }
    
    // a user post a location
    func addRelation (location: Location, user: User, comment: String) {
        if UserLoctionRelation[location] != nil {
            UserLoctionRelation[location]!.append([user: comment])
        }
        else {
            print("location \(location.getName()) does not exist")
        }
        saveRelation()
    }
    
    // function to add like
    func addLike(location: Location, user: User) {
        print("added user \(user.getName()) likes \(location.getName())")
        likeLocation.append([user: location])
        saveLike()
    }
    
    // function to delete a user like a location
    func deleteLike(location: Location, user: User) {
        var i = 0
        for dic in likeLocation {
            if dic.first?.key.getEmail() == user.getEmail() && dic.first?.value.getName() == location.getName() {
                likeLocation.remove(at: i)
                return
            }
            i += 1
        }
    }
    
    func updateCurrUser() {
        var i: Int = 0
        for user in users {
            if let curr = currentUser {
                if user.getEmail() == curr.getEmail() {
                    users[i] = curr
                    return
                }
                i+=1;
            }
        }
    }
    
    func updateCurrLoc() {
        var i: Int = 0
        for location in locations {
            if let curr = currentLocation {
                if location.getName() == curr.getName() {
                    locations[i] = curr
                    return
                }
                i+=1
            }
        }
    }
    
    
    // save all of the user to the plist file
    func saveUsers() {
        updateCurrUser()
        updateCurrLoc()
        var userArray = [[String: String]]()
        for user in users {
            let userDic = [kUsernameKey: user.getName(),
                           kUserEmailKey: user.getEmail(),
                           kUserNumPost: String(user.getNumPost()),
                           kUsernumLikes: String(user.getNumLikes())]
            userArray.append(userDic)
        }
        ref?.child("User").setValue(userArray as NSArray)
        print("user written to DB")
    }
    
    // save all of the locations to the plist file
    func saveLocations() {
        updateCurrUser()
        updateCurrLoc()
        var locationArray = [[String: String]]()
        for location in locations {
            let locationDic = [kLocationNameKey: location.getName(),
                               kLocationLatiKey: String(location.getLatitude()),
                               kLocationLongKey: String(location.getLongitude()),
                               kLocationNumLikeKey: String(location.getNumLike())]
            locationArray.append(locationDic)
        }
        ref?.child("Location").setValue(locationArray as NSArray)
        print("location written to DB")
    }
    
    // save user-location relation to the plist file
    func saveRelation() {
        updateCurrUser()
        updateCurrLoc()
        var relationArray = [[String: String]]() // each dictionary store all info of an edge
        
        // var relationDic = [String: [[String: String]]]()
        for pair in UserLoctionRelation {
            // get the coordinate string
            let coordinate = String(pair.key.getLatitude()) + "," + String(pair.key.getLongitude())
            
            for user in pair.value {
                let relationDic = [kRelationLocCoorKey: coordinate,
                                   kRelationUserEmail: user.first?.key.getEmail(),
                                   kRelationUserComment: user.first?.value]
                relationArray.append(relationDic as! [String : String])
            }
        }
        ref?.child("Relation").setValue(relationArray as NSArray)
        print("relation written to DB")
    }
    
    func saveLike() {
        updateCurrUser()
        updateCurrLoc()
        var likeArray = [[String: String]]()
        for dic in likeLocation {
            // get user and loc
            let user = dic.first?.key
            let loc = dic.first?.value
            if let user = user, let loc = loc {
                let coor = "\(String(loc.getLatitude())),\(String(loc.getLongitude()))"
                likeArray.append([kLikeUser: user.getEmail(),
                                  kLikeLocation: coor])
            }
        }
        ref?.child("Like").setValue(likeArray as NSArray)
        print("Like written to DB")
    }
    
    // function to save profile image to document directory
    // imageName is the email of the user storing the profilepic
    func saveProfileImage(image: UIImage, imageName: String){
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let directoryPath = url!.appendingPathComponent("profilePic").path
        
        // create directory if the directory does not exist
        createDirectory(path: directoryPath)
        
        // create reference to the target file of storage
        let imageRef = storageRef.child("profilePic/\(imageName).jepg")
        
        // get data object of the image
        let imgData = image.jpeg(.low)
        
        // write to DB
        self.writeImageTODB(data: imgData, imageRef: imageRef)
    }
    
    // function to save location image
    func saveLocationImage(image: UIImage, imageName: String, locationCoordinate: String) {
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let directoryPath = url!.appendingPathComponent("locationPic").path
        
        // create directory if the directory does not exist
        createDirectory(path: directoryPath)
        
        // create the coordinate file of the location if it does not exist
        let coordinatePath = url!.appendingPathComponent("locationPic/" + locationCoordinate).path
        createDirectory(path: coordinatePath)
        
        // create reference to the target file of storage
        let imageRef = storageRef.child("locationPic/\(locationCoordinate)/\(imageName).jepg")
        
        // get data object of the image
        let imgData = image.jpeg(.low)
        
        // write to DB
        self.writeImageTODB(data: imgData, imageRef: imageRef)
    }
    
    func writeImageTODB(data: Data?, imageRef: StorageReference) {
        // Upload the file to path
        _ = imageRef.putData(data!, metadata: nil)
    }
    
    func getImage(imageName: String, toShow: UIImageView, locOrProf: String) {
        let islandRef = storageRef.child("\(imageName)")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("unable to obtain image: \(error.localizedDescription)")
                
                // if it is prof pic, show the default prof pic
                if locOrProf == "prof" {
                    toShow.image = UIImage(named: "defaultProfile")
                }
                else {
                    toShow.image = nil
                }
                
                // Uh-oh, an error occurred!
            } else {
                // Data for is returned
                toShow.image = UIImage(data: data!)
            }
        }
    }
    
    func createDirectory(path: String) {
        // create directory if the directory does not exist
        if !manager.fileExists(atPath: path) {
            do {
                try manager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("error: \(error)")
            }
        }
    }
    
    // function to find the user with the specific email
    func findUser(email: String) -> User? {
        for user in users{
            if user.getEmail() == email {
                return user
            }
        }
        return nil
    }
    
    // function to find the location with the specific coordinate
    func findLocation(coordinate: String) -> Location? {
        for location in locations {
            let latiString = String(location.getLatitude())
            let longiString = String(location.getLongitude())
            if latiString + "," + longiString == coordinate {
                return location
            }
        }
        return nil
    }
    
    // function to find location by name
    func findLocationByName(by name: String) -> Location? {
        for location in locations{
            if location.getName() == name {
                return location
            }
        }
        return nil
    }
    
    // find a pair of relation
    func findRelation(location: Location, user: User) -> Bool {
        let allUsersLikingCurrentLoc = UserLoctionRelation[location]
        if let _ = allUsersLikingCurrentLoc {
            for relation in allUsersLikingCurrentLoc! {
                if relation.first?.key.getEmail() == user.getEmail() {
                    return true
                }
            }
        }
        return false
    }
    
    func findLike(location: Location, user: User) ->Bool {
        for dic in likeLocation {
            if dic.first?.key.getEmail() == user.getEmail() && dic.first?.value.getName() == location.getName() {
                return true
            }
        }
        return false
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    // Returns the data for the specified image in JPEG format.
    // return A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
