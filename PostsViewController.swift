//
//  PostsViewController.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/12/4.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import UIKit

class PostsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // data model
    private var data = DataModel.sharedInstance
    
    @IBOutlet weak var numPeople: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    let reuseIdentifier = "Cell"
    // remember cell
    var mCell : PostCollectionViewCell?
    
    // array of heights to remember the y coordinate of each cell
    var totalHeights = [CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    


    override func viewWillAppear(_ animated: Bool) {
        backImage.image = Helper.helper.getBackground()
        // set the like labels
        numPeople.text = "\(data.currentLocation?.getNumLike() ?? 0) people like this location"
        
        // get whether current user like the current place
        if data.findLike(location: data.currentLocation!, user: data.currentUser!) {
            likeButton.setImage(UIImage(named: "upvoted"), for: .normal)
        }
        else {
            likeButton.setImage(UIImage(named: "notUpvoted"), for: .normal)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {        
        if data.currentLocation == nil {
            print ("do not know current location")
            return 0
        }
        else {
            if let allLike = data.getRelations()[data.currentLocation!] {
                if allLike.count == 0 {
                    return 1
                }
                return allLike.count
            }
            else {
                print("location not found in relation map")
                return 0
            }
        }
    }

    @IBAction func tanggleLike(_ sender: UIButton) {
        if likeButton.currentImage == UIImage(named: "upvoted") {
            likeButton.setImage(UIImage(named: "notUpvoted"), for: .normal)
            data.currentUser?.decLike()
            data.currentLocation?.decLike()
            data.deleteLike(location: data.currentLocation!, user: data.currentUser!)
        }
            
        else {
            likeButton.setImage(UIImage(named: "upvoted"), for: .normal)
            data.currentUser?.incLike()
            data.currentLocation?.incLike()
            data.addLike(location: data.currentLocation!, user: data.currentUser!)
        }
        data.saveUsers()
        data.saveLocations()
        data.saveLike()
        numPeople.text = "\(data.currentLocation?.getNumLike() ?? 0) people like this location"
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCollectionViewCell
        
        // Configure the cell
        cell.backgroundColor = .clear
        if data.currentLocation == nil {
            print ("do not know current location")
        }
        else if let currLoc = data.currentLocation{
            if let allLike = data.getRelations()[data.currentLocation!] {
                // if for the location, the user and comment exist, grab the data and show them
                if let user = allLike[indexPath.row].first?.key, let comment = allLike[indexPath.row].first?.value  {
                    // set the profile picture and make it circular
                    data.getImage(imageName: "profilePic/\(user.getEmail()).jepg", toShow: cell.profilePic, locOrProf: "prof")
                    // cell.profilePic.image = data.getProfilePic(of: user.getEmail())
                    cell.profilePic.layer.masksToBounds = true
                    cell.profilePic.layer.cornerRadius = cell.profilePic.frame.width/2
                    
                    // set the labels
                    cell.name.text = user.getName()
                    cell.comment.text = comment
                    let coor = Helper.helper.getCoordinateStringByDoubles(latitude: currLoc.getLatitude(), longitude: currLoc.getLongitude())
                    data.getImage(imageName: "locationPic/\(coor)/\(user.getEmail()).jepg", toShow: cell.postPic, locOrProf: "loc")
                    // cell.postPic.image = data.getPostPic(of: currLoc, by: user)
                }
                else {
                    cell.profilePic.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                    cell.name.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                    cell.comment.text = "No post yet"
                    cell.postPic.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                }
                
                if cell.postPic.image == nil {
                    print("attemping to shrink imageview")
                    cell.postPic.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                }
            }
            else {
                print("location not found in relation map")
            }
        }
        mCell = cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backTapped(_ sender: Any) {
        Helper.helper.SwitchToTabBarVC()
    }
    
}
