//
//  LocationProvider.swift
//  Ramble
//
//  Created by Sam Jones on 5/17/24.
//

import Foundation
import SCSDKCameraKit
import CoreLocation

class LocationProvider: NSObject, LocationDataProvider, CLLocationManagerDelegate {
    var location: CLLocation?
    let locationManager = CLLocationManager()
    
    override init() {
        
        super.init()
        locationManager.delegate = self
        requestLocationPermission()
        locationManager.startUpdatingLocation()
    }
    
    
    func startUpdating(with parameters: LocationParameters) {
        
        locationManager.desiredAccuracy = parameters.desiredAccuracy
        locationManager.distanceFilter = parameters.distanceFilterMeters
        locationManager.startUpdatingLocation()
        
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    private func requestLocationPermission() {
        
        let status = CLLocationManager().authorizationStatus

             switch status {
                 
             case .notDetermined:
                 CLLocationManager().requestWhenInUseAuthorization()
             case .authorizedWhenInUse, .authorizedAlways:
                 print("location authorized")
             default:
                 CLLocationManager().requestWhenInUseAuthorization()
                 print("location not authorized")
             }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.first else {
            print("no location")
            return
        }
        var buckingHamPalace = CLLocation(latitude: 51.5017108, longitude: -0.141184)
        var testLocation = CLLocation(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
        location = buckingHamPalace
        print("location: \(testLocation)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
          print("Failed to get location: \(error.localizedDescription)")
      }
    
}
