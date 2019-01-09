//
//  User.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/11/27.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import Foundation

class User: Hashable{
    private var name: String
    private var email: String
    private var numPost: Int
    private var numLikes: Int
    
    // code that make the location class hashable
    static func == (lhs: User, rhs: User) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    
    init(name: String, email: String, numPost: Int = 0, numLikes: Int = 0) {
        self.name = name
        self.email = email
        self.numPost = numPost
        self.numLikes = numLikes
    }
    
    func setName(name: String){
        self.name = name
    }
    
    func setEmail(email: String){
        self.email = email
    }
    
    func setNumPost(numPost: Int){
        self.numPost = numPost
    }
    
    func setNumLikes(numLikes: Int){
        self.numLikes = numLikes
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getEmail() -> String {
        return self.email
    }
    
    func getNumPost() -> Int{
        return numPost
    }
    
    func getNumLikes() -> Int {
        return numLikes
    }
    
    func incPost() {
        numPost += 1
        print(numPost)
    }
    
    func incLike() {
        numLikes += 1
    }
    
    func decLike() {
        numLikes -= 1
    }
}
