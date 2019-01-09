//
//  UserModel.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/11/27.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import Foundation

class DataModel{
    private var users: [User];
    static let sharedInstance = DataModel() // Singleton
    private var filepath: String
    var currentUser : User? // no user has logged in --> no current user
    
    // keys in the plist
    let kUsernameKey = "Username"
    let kUserEmailKey = "UserEmail"
    let kUserNumPost = "numPost"
    let kUsernumLikes = "numLikes"
    let kUsersPlist = "Users.plist"
    init() {
        // read in from user.plist to read in all of the users, the first of which is always the current user logged in
        users = [User]()
        
        // load the file manager to find the Document directory
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        filepath = url!.appendingPathComponent(kUsersPlist).path
        print(filepath)
        
        if manager.fileExists(atPath: filepath){
            let usersArray = NSArray(contentsOfFile: filepath)
            
            // make sure that the data is able to be put into an NSArray
            if let usersA = usersArray {
                for dic in usersA {
                    let userDic = dic as! [String: String]
                    let newUser = User(name: userDic[kUsernameKey]!, email: userDic[kUserEmailKey]!, numPost: Int(userDic[kUserNumPost]!) ?? 0 , numLikes: Int(userDic[kUsernumLikes]!) ?? 0)
                    users.append(newUser)
                }
            }
        }
        
        else{
            let user1 = User(name: "John", email: "john@gmail.com")
            let user2 = User(name: "Peter", email: "peter@gmail.com")
            let user3 = User(name: "Jude", email: "jude@gmail.com")
            let user4 = User(name: "David", email: "david@gmail.com")
            users = [user1, user2, user3, user4]
        }
    }
    func getUsers() -> [User]{
        return users
    }
    
    // function to get the current user
    func getCurrentUser(email: String){
        // find the user with the current email
        for user in users{
            if user.getEmail() == email {
                currentUser = user
            }
        }
        print("current user is now the one with email \(email)")
    }
    
    // add user
    func addUser (newUser: User) {
        users.append(newUser)
        saveUsers()
        print("user \(newUser.getName()) added")
    }
    
    // save all of the user to the plist file
    func saveUsers() {
        var userArray = [[String: String]]()
        for user in users {
            let userDic = [kUsernameKey: user.getName(),
                           kUserEmailKey: user.getEmail(),
                           kUserNumPost: String(user.getNumPost()),
                           kUsernumLikes: String(user.getNumLikes())]
            userArray.append(userDic)
        }
        (userArray as NSArray).write(toFile: filepath, atomically: true)
        print("written to plist")
    }
}
