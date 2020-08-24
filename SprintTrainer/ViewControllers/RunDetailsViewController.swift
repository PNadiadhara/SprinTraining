//
//  RunDetailsViewController.swift
//  SprintTrainer
//
//  Created by Pritesh Nadiadhara on 8/22/20.
//  Copyright © 2020 PriteshN. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class RunDetailsViewController: UIViewController {

    var run: Run!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
    }
    
    private func configureView(){
        let distance = Measurement(value: run.distance, unit: UnitLength.meters)
        let seconds = Int(run.duration)
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedDate = FormatDisplay.date(run.timestamp)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
        
        distanceLabel.text = "Distance:  \(formattedDistance)"
        dateLabel.text = formattedDate
        timeLabel.text = "Time:  \(formattedTime)"
        paceLabel.text = "Pace:  \(formattedPace)"
    }
    
    private func mapRegion() -> MKCoordinateRegion? {
        guard
            let locations = run.locations,
        locations.count > 0
            else {
                return nil
        }
        let latitudes = locations.map { location -> Double in
            let location = location as! Location
            return location.latitude
        }
        let longitudes = locations.map { location -> Double in
            let location = location as! Location
            return location.longitude
        }
        
        let maxLat = latitudes.max()!
        let MaxLong = longitudes.max()!
        let minLat = latitudes.max()!
        let minLong = longitudes.max()!
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLong + MaxLong) / 2)
        // span used to add space on mapview
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.25, longitudeDelta: (MaxLong - minLong) * 1.25)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    private func polyLine() -> MKPolyline {
        guard let locations = run.locations else {
            return MKPolyline()
        }
        
        let coords: [CLLocationCoordinate2D] = locations.map { location in
            let location = location as! Location
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
        }
        return MKPolyline(coordinates: coords, count: coords.count)
        
    }
    
    private func loadMap() {
        guard let locations = run.locations, locations.count > 0, let region = mapRegion()
            else {
                let alert = UIAlertController(title: "Error", message: "No saved locations Found", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                present(alert,animated: true)
                return
        }
        mapView.setRegion(region, animated: true)
        mapView.addOverlay(polyLine())
    }


}

extension RunDetailsViewController: MKMapViewDelegate {
    // Add pathline to map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .black
        renderer.lineWidth = 3
        return renderer
    }
}
