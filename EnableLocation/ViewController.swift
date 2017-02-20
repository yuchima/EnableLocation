//
//  ViewController.swift
//  EnableLocation
//
//  Created by Yuchi on 2/9/17.
//  Copyright © 2017 Yuchi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GooglePlaces


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    @IBOutlet var pID: UILabel!
    @IBOutlet var pName: UILabel!
    @IBOutlet var pAddress: UILabel!
    @IBOutlet var pType: UILabel!
    @IBOutlet var pAttrib: UILabel!

    @IBOutlet var mapView: MKMapView!

    @IBOutlet var lat: UILabel!
    @IBOutlet var lon: UILabel!

    
    var placesClient: GMSPlacesClient!
    var placeid: String!
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        
        if (CLLocationManager.locationServicesEnabled()){
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
        }
    }

    
    func locationManager (_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation] ){
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta:1, longitudeDelta:1))
        self.mapView.setRegion(region, animated:true)
        self.lat.text = "lat: \(location!.coordinate.latitude)"
        self.lon.text = "lon: \(location!.coordinate.longitude)"
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error" + error.localizedDescription)
    }
    
    @IBAction func getCurrentPlace(_ sender: UIButton){
        
        placesClient.currentPlace { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("pick place error: \(error.localizedDescription)")
                return
            }
            
            self.pName.text = "No current place"
            self.pAddress.text = ""
            
            if let placeLikelihoodList =  placeLikelihoodList{
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.pName.text = place.name
                    self.pAddress.text = place.formattedAddress?.components(separatedBy: ", ").joined(separator: "\n")
                    self.pID.text = place.placeID
                    self.placeid = place.placeID
                    self.pAttrib.text = "\(place.attributions)"
                }
            }
        }
    
    }
    
    @IBAction func lookupPlaceID(_ sender: UIButton){
        
        
        placesClient.lookUpPlaceID(placeid, callback: {(place, error) -> Void in
           
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
//
            guard let place = place else {
                print("No place details for \(self.placeid)")
                return
            }
            
            self.pType.text = "\(place.types)"
            
        })
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

