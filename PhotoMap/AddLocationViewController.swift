//
//  AddLocationViewController.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/11/30.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import UIKit
import Photos
import CoreLocation


class AddLocationViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {

    // location gotten from mapVC
    var location: CLLocation? = nil
    
    // data model
    private var data = DataModel.sharedInstance
    
    // IB outlets
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var userTextView: UITextView!
    @IBOutlet weak var uploadedImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet var longTapGesture: UILongPressGestureRecognizer!
    @IBOutlet weak var backTap: UITapGestureRecognizer!
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var backImage: UIImageView!
    // image picker
    var picker = UIImagePickerController()
    
    // adjust style of status bar
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up image picker
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        // set navigation bar to transparent
        naviBar.setBackgroundImage(UIImage(), for: .default)
        naviBar.shadowImage = UIImage()
        naviBar.isTranslucent = true
        
        if uploadedImageView.image != nil {
            // enable tap gestures on the image once an image is uploaded
            tapGesture.isEnabled = true
            longTapGesture.isEnabled = true
        }
        else {
            tapGesture.isEnabled = false
            longTapGesture.isEnabled = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // enable tap gestures on the image once an image is uploaded
        if uploadedImageView.image != nil {
            print("tap and long tap enabled")
            tapGesture.isEnabled = true
            longTapGesture.isEnabled = true
        }
        else {
            print("tap and long tap disabled")
            tapGesture.isEnabled = false
            longTapGesture.isEnabled = false
        }
        // backTap.require(toFail: tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check photo permission
        checkPermission()
        
        // get string version of coordinate
        coordinateLabel.text = Helper.helper.getCoordinateStringFromCL(location: location)
        
        // reverse geocoding the location
        reverseGeocoding()
        
        // handle post button
        enablePost(image: uploadedImageView.image, text: userTextView.text)
        
        // set up background image
        backImage.image = Helper.helper.getBackground()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    // method to fetch image and show it on the image view
    // a user can only choose one image
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
        
        uploadedImageView.image = newImage
        addImageButton.alpha = 0 // do not allow the user to see the button once an image is selected
        enablePost(image: uploadedImageView.image, text: userTextView.text)
        picker.dismiss(animated: true)
    }
    
    // called when the user change the text
//    func textViewDidChange(_ textView: UITextView) {
//
//    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let allText = userTextView.text ?? ""
        if text.count > 0 || allText.count-1 > 0 ||  uploadedImageView.image != nil{
            postButton.isEnabled = true
        }
        else {
            postButton.isEnabled = false
        }
        return true
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    // cancel clicked --> return to the mapview
    @IBAction func CancelClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // add icon tapped, show the image selection view
    @IBAction func addImageClicked(_ sender: UIButton) {
        self.present(picker, animated: true, completion: nil)
    }
    
    // if image is tapped, the user can choose to upload another image
    @IBAction func ImageTapped(_ sender: UITapGestureRecognizer) {
        print("image tapped")
        self.present(picker, animated: true, completion: nil)
    }
    
    // if the image is long tapped, delete the picture
    @IBAction func ImageLongTapped(_ sender: UILongPressGestureRecognizer) {
        print("image long tapped")
        let alert = UIAlertController(title: "Photo delete", message: "Are you sure you do not want to share this picture?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) {(action) in
            self.uploadedImageView.image = nil
            self.addImageButton.alpha = 0.9
        }
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
        enablePost(image: uploadedImageView.image, text: userTextView.text)
    }
    
    @IBAction func BackgroundTapped(_ sender: UITapGestureRecognizer) {
        userTextView.resignFirstResponder()
    }
    
    // post tapped, save the image, text, and location to the data model
    @IBAction func postTapped(_ sender: UIBarButtonItem) {
        print("post tapped")
        if let coordinate = coordinateLabel.text, let locationName = locationLabel.text  {
            // get image and text
            let image = uploadedImageView.image ?? nil
            let text = userTextView.text ?? ""
            
            // location does not exist, add to location array and relation map
            var loc = data.findLocationByName(by: locationName)
            if loc == nil {
                let coordinates = getCoordinate(coordinate: coordinate)
                loc = Location(name: locationName, latitude: coordinates[0], longitude: coordinates[1], numLike: 0)
                data.addLocation(newLocation: loc!)
            }
            
            // no matter if the location is new or not, add the post
            data.addRelation(location: loc!, user: data.currentUser!, comment: text) // it is fine if the user does not add any comment
            data.currentUser!.incPost() // increament numpost of the user
            data.saveUsers()
            if image != nil {
                data.saveLocationImage(image: image!, imageName: (data.currentUser?.getEmail())!, locationCoordinate: Helper.helper.translateCoordinate(coordinate: coordinate))
            }
        }
        // self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func getCoordinate(coordinate: String) -> [Double]{
        // parse the coordinate string
        var coordinates = [Double]()
        let coordinatesRaw = coordinate.components(separatedBy: ", ")
        let latiMangitude = coordinatesRaw[0].components(separatedBy: "°")[0]
        let latiSign = coordinatesRaw[0].components(separatedBy: "°")[1]
        let longiMangitude = coordinatesRaw[1].components(separatedBy: "°")[0]
        let longiSign = coordinatesRaw[1].components(separatedBy: "°")[1]
        
        // get the value of the coordinate
        if latiSign == "N" {
            coordinates.append(Double(latiMangitude) ?? 0.0)
        }
        else {
            coordinates.append(0.0 - (Double(latiMangitude) ?? 0.0))
        }
        if longiSign == "E" {
            coordinates.append(Double(longiMangitude) ?? 0.0)
        }
        
        else {
            coordinates.append(0.0 - (Double(longiMangitude) ?? 0.0))
        }
        print("latitude: \(coordinates[0])")
        print("longitude: \(coordinates[1])")
        return coordinates
    }
    
    func reverseGeocoding() {
        let geoCoder = CLGeocoder()
        if let locationActual = location {
            geoCoder.reverseGeocodeLocation(locationActual) { (placemarks, error) in
                // Process Response
                self.processResponse(withPlacemarks: placemarks, error: error)
            }
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            locationLabel.text = "Unable to Find Address for Location"
            
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                if let address = placemark.compactAddress {
                    print(address)
                    locationLabel.text = address
                }
            } else {
                print("No Matching Addresses Found")
            }
        }
    }
        
    func enablePost(image: UIImage?, text: String?) {
        if let text = text {
            if image == nil && text.count == 0 {
                postButton.isEnabled = false
            }
        }
        if image != nil{
            postButton.isEnabled = true
        }
    }
    
    
    
    // MARK: - Navigation

//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//
//
//    }
}

// extends CLPlacemark to obtain full address
extension CLPlacemark {
    var compactAddress: String? {
        if let name = name {
            var result = name
            if let city = locality {
                result += ", \(city)"
            }
            if let country = country {
                result += ", \(country)"
            }
            return result
        }
        return nil
    }
}
