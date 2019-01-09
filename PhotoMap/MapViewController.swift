//
//  MapViewController.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/11/19.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    private var data = DataModel.sharedInstance
    static let sharedInstance = MapViewController()
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // get the user's current location and shows it on the map
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let location = locationManager.location {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("called")
        loadAnotation()
        mapView.reloadInputViews()
    }
    
    func loadAnotation() {
        data.loadData()
        // create the annotations in terms of the location array in the datamodel
        for location in data.getLocations() {
            let latitude = location.getLatitude()
            let longitude = location.getLongitude()
            let name = location.getName()
            
            let annotation = MKPointAnnotation()
            annotation.title = name
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    // called whent the pin is tapped --> show a callout view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.coordinate.latitude == mapView.userLocation.coordinate.latitude &&
            annotation.coordinate.longitude == mapView.userLocation.coordinate.longitude{
            print("my location: \(mapView.userLocation.coordinate.latitude), \(mapView.userLocation.coordinate.longitude)")
            return nil
        }
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        annotationView.markerTintColor = .clear
        annotationView.glyphTintColor = .clear
        annotationView.glyphImage = UIImage()
        annotationView.image = UIImage(named: "photo")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton.init(type: UIButton.ButtonType.detailDisclosure)
        return annotationView
    }
    
    // called when the call out accessory control is tapped --> bring to the detail view controller
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        // jump to the location detailed view
        Helper.helper.SwitchToDetailCVC()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // find the location associate with the annotationview
        let coorString = Helper.helper.getCoordinateStringFromCLC(location: view.annotation?.coordinate)
        print("coordinate: \(String(describing: coorString))")
        print("setting current location")
        data.currentLocation = data.findLocation(coordinate: coorString ?? "")
        if let loc = data.currentLocation{
            print("currentlocation set to \(loc.getName())")
        }
        else {
            print("location not set")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Could not get location")
        print(error.localizedDescription)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddLocationSegue", let alvc = segue.destination as? AddLocationViewController {
            alvc.location = mapView.userLocation.location
        }
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 
}
