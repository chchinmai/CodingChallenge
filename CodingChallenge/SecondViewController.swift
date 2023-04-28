//
//  SecondViewController.swift
//  CodingChallenge
//
//  Created by chinmai swaraj on 27/4/2023.
//

import UIKit
import MapKit
import CoreLocation

class LocationAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D

    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

class SecondViewController: UIViewController,  CLLocationManagerDelegate {

    var myStruct: Person?
    
    @IBOutlet weak var locationValue: UILabel!
    @IBOutlet weak var statusValue: UILabel!
    @IBOutlet weak var typeValue: UILabel!
    @IBOutlet weak var ctValue: UILabel!
    @IBOutlet weak var decValue: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("myStruct",myStruct!)
        // Do any additional setup after loading the view.
        locationValue.text = (myStruct?.location)!
        statusValue.text = (myStruct?.status)!
        typeValue.text = (myStruct?.type)!
         
        
        // Create a DateFormatter to parse the date string
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        // Parse the date string into a Date object
        if let date = inputFormatter.date(from: (myStruct?.callTime)!) {
            // Create another DateFormatter to format the Date object into the desired string format
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d, yyyy h:mm a"
            outputFormatter.timeZone = TimeZone.current

            // Format the Date object into a string
            let dateString = outputFormatter.string(from: date)

            // Set the formatted string as the text of a label
            ctValue.text = dateString
        }
        
        if let myOptionalValue = myStruct?.description {
            let lines = myOptionalValue.components(separatedBy: "\n")
            print(lines)
            let outputString = lines.joined(separator: ", ")
            print(outputString)
            let newString = outputString.replacingOccurrences(of: ",", with: "\n")
            print(newString)
            decValue.text  = newString
        } else {
            decValue.text = ""
        }
        
        let DirectionBtn = UIBarButtonItem(title: "Direction", style: .plain, target: self, action: #selector(showdirection))
        self.navigationItem.setRightBarButton(DirectionBtn, animated: false)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        
        
        if let existingItem = navigationItem.leftBarButtonItem {
            existingItem.title = "Back"
        } else {
            let newItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(someAction))
            navigationItem.leftBarButtonItem = newItem
        }
        
//        let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
//
//        view.addSubview(mapView)
        
//        let location = CLLocationCoordinate2D(latitude: myStruct!.latitude, longitude: myStruct!.longitude)
//        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        let region = MKCoordinateRegion(center: location, span: span)
//        mapView.setRegion(region, animated: true)

        mapView.showsUserLocation = true
        showLocationOnMap(latitude: myStruct!.latitude, longitude: myStruct!.longitude, title: myStruct!.status, subtitle: myStruct!.callTime)
    


    }
    func showLocationOnMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String?, subtitle: String?) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 1000
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(region, animated: true)

        let annotation = LocationAnnotation(title: title, subtitle: subtitle, coordinate: location.coordinate)
        mapView.addAnnotation(annotation)
    }
    
    @objc func showdirection(){
        print("showdirection Function")
        
        if let currentLocation = locationManager.location {
            print("currentLocation",currentLocation)
            let destination = CLLocationCoordinate2D(latitude: myStruct!.latitude, longitude: myStruct!.longitude) // Example destination location
            let destinationPlacemark = MKPlacemark(coordinate: destination)
            let mapItem = MKMapItem(placemark: destinationPlacemark)
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: options)
        }

        

    }
    @objc func someAction(){
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
            }
        }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Do something with the latitude and longitude values
        print("Latitude: \(latitude), Longitude: \(longitude)")
        
        // Stop updating the location once we have it
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
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
