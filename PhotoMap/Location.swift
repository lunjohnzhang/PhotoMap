//
//  Location.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/11/30.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import Foundation

class Location: Hashable {
    // code that make the location class hashable
    static func == (lhs: Location, rhs: Location) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    private var name: String
    private var latitude: Double
    private var longitude: Double
    private var numLike: Int
    
    init(name: String, latitude: Double, longitude: Double, numLike: Int){
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.numLike = numLike
    }
    
    func getName() -> String {
        return name
    }
    
    func getLatitude() -> Double {
        return latitude
    }
    
    func getLongitude() -> Double {
        return longitude
    }
    
    func getNumLike() -> Int {
        return numLike
    }
    
    func incLike() {
        numLike += 1
    }
    
    func decLike() {
        numLike -= 1
    }
}
