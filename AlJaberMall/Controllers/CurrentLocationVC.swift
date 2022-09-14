//
//  CurrentLocationVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 28/02/2021.
//

import UIKit
import GooglePlacesSearchController
import GoogleMaps
import CoreLocation
import GooglePlaces

protocol confirmDelegate {
    func confirmComplition(placeMark: CLPlacemark, location: CLLocationCoordinate2D)
}

extension confirmDelegate {
    func confirmComplition(placeMark: CLPlacemark, location: CLLocationCoordinate2D) {}
}

class CurrentLocationVC: UIViewController, GMSMapViewDelegate, GooglePlacesAutocompleteViewControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBOutlet var mapView: GMSMapView!
    var marker = GMSMarker()
    let googleSearchPlaceApiKey = "AIzaSyD1kcvA9bCB2gLdafDblO0ohkYzXoB0LUM"
    
    var initMyLocation = false
    
    var locationManager = CLLocationManager()
    
    var placeMark: CLPlacemark?
    var location: CLLocationCoordinate2D?
    
    var confirmDelegate: confirmDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Your Address"
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        self.searchView.layer.cornerRadius = 20
        self.confirmBtn.layer.cornerRadius = 25
        
        self.navigationText(title: "Location".localized())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorBlack()
    }
    
    func viewController(didAutocompleteWith place: PlaceDetails) {
        print(place.description)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last

        if !initMyLocation {
            getMyLocation(userLocation)
            initMyLocation = true
        }

        // locationManager.stopUpdatingLocation()
    }
    
    fileprivate func getMyLocation(_ userLocation: CLLocation?) {
        if userLocation == nil {
            return
        }
        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)

        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: 15)
        mapView.camera = camera

        mapView.animate(toLocation: center)

        mapView.isMyLocationEnabled = true
        
        marker.position = center
        marker.title = "Your address"
        //marker.snippet = "your snippet"
        marker.map = mapView
        
        // geoCoding(location: location)
        
    }
    
    @IBAction func searchAction(sender: UIButton) {
        let controller = GooglePlacesSearchController(delegate: self, apiKey: googleSearchPlaceApiKey, placeType: PlaceType.address, searchBarPlaceholder: "Enter You address")
        
        present(controller, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        marker.position = position.target
        print(marker.position)
        
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        marker.position = position.target
        self.getAddressFromLatLon(pdblLatitude: String(position.target.latitude), withLongitude: String(position.target.longitude))
    }
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let lat: Double = Double("\(pdblLatitude)")!
            //21.228124
            let lon: Double = Double("\(pdblLongitude)")!
            //72.833770
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lon
            self.location = center
        
            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)


            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    
                    guard let plm = placemarks else {
                        return
                    }
                    
                    let pm = plm as [CLPlacemark]
                    
                    if pm.count > 0 {
                        let pm = plm[0]
                        
                        self.placeMark = pm
                        print(pm.country)
                        print(pm.locality)
                        print(pm.subLocality)
                        //print(pm.thoroughfare)
                        //print(pm.postalCode)
                        //print(pm.subThoroughfare)
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
//                        if pm.postalCode != nil {
//                            addressString = addressString + pm.postalCode! + " "
//                        }

                        self.addressLbl.text = addressString
                        print(addressString)
                  }
            })

        }
    
    @IBAction func confirmAction(sender: UIButton) {
        if self.placeMark != nil && location != nil {
            self.confirmDelegate?.confirmComplition(placeMark: self.placeMark!, location: self.location!)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
