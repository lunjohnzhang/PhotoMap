//
//  UserViewController.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/11/30.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import UIKit
import Photos

class UserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // data model
    var data = DataModel.sharedInstance
    
    // IBOutlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numPostsLabel: UILabel!
    @IBOutlet weak var numLikesLabel: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    
    // image picker
    let picker = UIImagePickerController()
    
    // set the bar style
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up current user
        let currUser = data.currentUser!
        // profilePic.image = data.getProfilePic(of: currUser.getEmail())
        data.getImage(imageName: "profilePic/\(currUser.getEmail()).jepg", toShow: profilePic, locOrProf: "prof")
        // set the profile picture circular
        profilePic.layer.masksToBounds = true
        profilePic.layer.cornerRadius = profilePic.frame.width/2
        nameLabel.text = currUser.getName()
        numPostsLabel.text = String(currUser.getNumPost())
        numLikesLabel.text = String(currUser.getNumLikes())
        
        // set up image picker
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        
    }
    
    // set background image
    override func viewWillAppear(_ animated: Bool) {
        backImage.image = Helper.helper.getBackground()
    }
    
    @IBAction func signOutTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .default) {(action) in
            Helper.helper.logOut()
        }
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeProfile(_ sender: UIButton) {
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var newImage: UIImage
        
        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        }
        else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        }
        else {
            return
        }
        
        // set the image and save the profile image to document
        profilePic.image = newImage
        data.saveProfileImage(image: newImage, imageName: (data.currentUser?.getEmail())!)
        picker.dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
