//
//  TrainingViewController.swift
//  SprintTrainer
//
//  Created by Pritesh Nadiadhara on 8/22/20.
//  Copyright © 2020 PriteshN. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class TrainingViewController: UIViewController {
    
    //hidding an element on the stack I.E. a button will cause it to use all the room in the stack on the story board
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var logoStackView: UIStackView!
    @IBOutlet weak var mapUIView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    let customCoolers = CustomCoolors()
    
    
    private var run: Run?
    
    //used to start and stop location services
    private let locationManager = LocationManager.shared
    // keeps track of points ran as CLLocation objects
    private var locationList: [CLLocation] = []
    
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        view.backgroundColor = customCoolers.celadonBlue
        navigationController?.setNavigationBarHidden(true, animated: true)
        startButtonSettings()
        navigationController?.hidesBarsOnTap = true
    }
    
   
    private func startButtonSettings() {
        startButton.layer.cornerRadius = startButton.frame.height * 0.20
        startButton.backgroundColor = customCoolers.yaleBlue
        startButton.setTitleColor(.white, for: .normal)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func startRun(){
        infoStackView.isHidden = false
        infoStackView.backgroundColor = customCoolers.yaleBlue
        logoStackView.isHidden = true
        startButton.isHidden = true
        stopButton.isHidden = false
        mapUIView.isHidden = false
        mapView.removeOverlays(mapView.overlays)
        stopButton.layer.cornerRadius = stopButton.frame.height * 0.20
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {_ in
            self.updateSeconds()
        }
        startLocationUpdates()
    }
    
    private func stopRun(){
           infoStackView.isHidden = true
           stopButton.isHidden = true
           startButton.isHidden = false
           logoStackView.isHidden = false
           mapUIView.isHidden = true
           
           locationManager.stopUpdatingLocation()
       }
    
    
    private func saveRun() {
        let newRun = Run(context: CoreDataStack.context)
        newRun.distance = distance.value
        newRun.duration = Int16(seconds)
        newRun.timestamp = Date()
        
        for location in locationList {
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRun.addToLocations(locationObject)
   
        }
        CoreDataStack.saveContext()
        
        run = newRun
    }

   
   
    func updateDisplay(){
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        // update outputUnit to be modular for future updates
        let formatedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: .minutesPerMile)
        
        
        distanceLabel.text = "Distance: \(formattedDistance)"
        timeLabel.text = "Time: \(formattedTime)"
        paceLabel.text = "Pace: \(formatedPace)"
    }
    
    
    func updateSeconds(){
        seconds += 1
        updateDisplay()
    }
  
    @IBAction func startTapped(_ sender: Any) {
        startRun()
        
    }
    
    @IBAction func stopTapped() {
       let alertController = UIAlertController(title: "End run?",
                                                message: "Do you wish to end your run?",
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
          self.stopRun()
          self.saveRun()
          self.performSegue(withIdentifier: .details, sender: nil)
        })
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
          self.stopRun()
          _ = self.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alertController, animated: true)
    }
    
    private func startLocationUpdates(){
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }
    
}

extension TrainingViewController : SegueHandlerType {
    enum SegueIdentifier: String {
        case details = "RunDetailsViewController"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .details:
            let destination = segue.destination as! RunDetailsViewController
            destination.run = run
        }
    }
}


extension TrainingViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else {
                continue
            }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
                let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                mapView.setRegion(region, animated: true)

            }
            
            locationList.append(newLocation)
        }
    }
}

extension TrainingViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = .blue
    renderer.lineWidth = 3
    return renderer
  }
}

