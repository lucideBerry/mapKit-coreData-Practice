//
//  DetailsVC.swift
//  travelBook
//
//  Created by Seçkin Denli on 16.02.2020.
//  Copyright © 2020 Seçkin Denli. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
class DetailsVC: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
   var locationManager = CLLocationManager()
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    var selectedTitle = ""
    var selectedID = UUID()
   
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    @IBOutlet weak var buytonn: UIButton!
    
    
//-------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        let gestureForHide = UITapGestureRecognizer(target: self, action: #selector(hidekeyboard))
        view.addGestureRecognizer(gestureForHide)
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chosenLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if selectedTitle != "" {
            buytonn.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedID.uuidString
            fetch.predicate = NSPredicate(format: "id = %@", idString)
            fetch.returnsObjectsAsFaults = false
            
            do{
         let result = try context.fetch(fetch)
                for result in result as! [NSManagedObject]{
                    if let title = result.value(forKey: "title") as? String {
                        annotationTitle = title
                        if let subtitle = result.value(forKey: "subtitle") as? String{
                         annotationSubtitle = subtitle
                            if let latitude = result.value(forKey: "latitude") as? Double {
                                annotationLatitude = latitude
                                if let longitude = result.value(forKey: "longitude") as? Double {
                                    annotationLongitude = longitude
                                    
                                    
                                    let annotation = MKPointAnnotation()
                                    annotation.title = annotationTitle
                                    annotation.subtitle = annotationSubtitle
                                    let cordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                    annotation.coordinate = cordinate
                                    mapView.addAnnotation(annotation)
                                    nameText.text = annotationTitle
                                    commentText.text = annotationSubtitle
                                    let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    let region = MKCoordinateRegion(center: cordinate, span: span)
                                    mapView.setRegion(region, animated: true
                                    )
                                }
                            }
                        }
                    }
                }
            }
            catch{print("error")
                
            }
        }
    }
    
    
    
    @objc func hidekeyboard (){view.endEditing(true) }
    
    
    @objc func chosenLocation (gestureRecognizer : UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            
            let touchedPoint = gestureRecognizer.location(in: mapView)
            let touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: mapView)
          
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            mapView.addAnnotation(annotation)
            
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedTitle == ""{
        let location = CLLocationCoordinate2D.init(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan (latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    }
   
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       
        if annotation is MKUserLocation{
        
            return nil
            
        }
    
    let reuseID = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            
            let Button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = Button
            
        } else {
            pinView?.annotation = annotation
            
        }
    return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if annotationTitle != "" {
        let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, Error) in
                
                if let placemark = placemarks{
                    if placemark.count > 0 {
                    let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.annotationTitle
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    
                    }
                    }
                }
                
                
            }
            
            
        }
    
    
    
    
    
    
    
    
    
    
    
    
   
    @IBAction func saveButton(_ sender: Any) {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(UUID(), forKey: "id")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        
        do{
        
        try context.save()
        print("congrat")
        }catch {print("error")}
       
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    
    
    
    
    
    
}
