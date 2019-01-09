//
//  Helper.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/11/27.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import CoreLocation

class Helper{
    static let helper = Helper()
    private var data = DataModel.sharedInstance
    func SwitchToTabBarVC() {
        // create main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // instantiate the map view
        let tabBarVC = storyboard.instantiateViewController(withIdentifier: "initalTabBarVC")
        
        // get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // set the tab bar view controller as root view
        appDelegate.window?.rootViewController = tabBarVC
        
    }
    
    func SwitchToDetailCVC() {
        // create main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // instantiate the map view
        let detailedNVC = storyboard.instantiateViewController(withIdentifier: "detailedNVC")
        
        // get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // set the tab bar view controller as root view
        appDelegate.window?.rootViewController = detailedNVC
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch let error{
            print(error)
        }
        
        // creating main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // instatiate the success view
        let LogInVC = storyboard.instantiateViewController(withIdentifier: "initialVC")
        
        // get the app delegate
        let appDeletegate = UIApplication.shared.delegate as! AppDelegate
        
        //set the success view controller as root view
        appDeletegate.window?.rootViewController = LogInVC
    }
    
    func getCoordinateStringFromCLC(location: CLLocationCoordinate2D?) -> String?{
        var result: String = ""
        if let latitude = location?.latitude, let longitude = location?.longitude {
            if latitude.sign == .plus {
                let temp = String(format: "%.4f", latitude.magnitude)
                result = "\(temp),"
            }
            else {
                let temp = String(format: "%.4f", latitude.magnitude)
                result += "-\(temp),"
            }
            if longitude.sign == .plus {
                let temp = String(format: "%.4f", longitude.magnitude)
                result += "\(temp)"
            }
            else {
                let temp = String(format: "%.4f", longitude.magnitude)
                result += "-\(temp)"
            }
        }
        if result != "" {
            return result
        }
        else {
            return nil
        }
    }
    
    // helper function to get the string version of the location
    func getCoordinateStringFromCL(location: CLLocation?) -> String?{
        var result: String = ""
        if let latitude = location?.coordinate.latitude, let longitude = location?.coordinate.longitude {
            if latitude.sign == .plus {
                let temp = String(format: "%.4f", latitude.magnitude)
                result = "\(temp)°N, "
            }
            else {
                let temp = String(format: "%.4f", latitude.magnitude)
                result += "\(temp)°S, "
            }
            if longitude.sign == .plus {
                let temp = String(format: "%.4f", longitude.magnitude)
                result += "\(temp)°E"
            }
            else {
                let temp = String(format: "%.4f", longitude.magnitude)
                result += "\(temp)°W"
            }
        }
        if result != "" {
            return result
        }
        else {
            return nil
        }
    }
    
    // get coordinate string by doubles
    func getCoordinateStringByDoubles(latitude: Double, longitude: Double) -> String {
        var result: String = ""
        result = String(latitude) + "," + String(longitude)
        return result
    }
    
    func translateCoordinate(coordinate raw: String) -> String {
        var result: String = ""
        let coordinatesRaw = raw.components(separatedBy: ", ")
        let latiRaw = coordinatesRaw[0].components(separatedBy: "°")
        let longiRaw = coordinatesRaw[1].components(separatedBy: "°")
        if latiRaw[1] == "N" {
            result += latiRaw[0] + ","
        }
        else {
            result += "-" + latiRaw[0] + ","
        }
        
        if longiRaw[1] == "E" {
            result += longiRaw[0]
        }
        else {
            result += "-" + longiRaw[0]
        }
        return result
    }
    
    // helper function to choose a random background image
    func getBackground() -> UIImage? {
        // since there are 12 background images intotal, generate a number between 1 and 12
        let number = Int.random(in: 1 ..< 13)
        return UIImage(named: "back\(number)")
    }
}
