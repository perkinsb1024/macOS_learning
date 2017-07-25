//
//  ViewController.swift
//  mapGuesser
//
//  Created by Ben Perkins on 7/24/17.
//  Copyright © 2017 Ben Perkins. All rights reserved.
//

import Cocoa
import MapKit

class ViewController: NSViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var questionLabel: NSTextField!
    @IBOutlet var scoreLabel: NSTextField!
    
    struct City {
        var name: String
        var location: CLLocationCoordinate2D
    }
    
    var currentCity = 0
    var score = 0 {
        didSet {
            scoreLabel.stringValue = "Score: \(score)"
        }
    }
    var gamePaused = false
    var clickRecognizer: NSClickGestureRecognizer!
    
    let cities = [City(name: "London", location: CLLocationCoordinate2D(latitude: 51.507351, longitude: -0.127758)),
                  City(name: "San Francisco", location: CLLocationCoordinate2D(latitude: 37.774929, longitude: -122.419416)),
                  City(name: "Reykjavíc", location: CLLocationCoordinate2D(latitude: 64.126521, longitude: -21.817439)),
                  City(name: "Moscow", location: CLLocationCoordinate2D(latitude: 55.755826, longitude: 37.6173)),
                  City(name: "Johannesburg", location: CLLocationCoordinate2D(latitude: -26.204103, longitude: 28.047305))]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(mapClicked))
        clickRecognizer.numberOfClicksRequired = 2
        mapView.addGestureRecognizer(clickRecognizer)
        mapView.delegate = self
        startGame()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func startGame() {
        score = 0
        currentCity = -1
        mapView.removeAnnotations(mapView.annotations)
        gamePaused = false
        nextCity()
    }
    
    func pauseGame() {
        gamePaused = true
        clickRecognizer.numberOfClicksRequired = 1
        questionLabel.stringValue = "Click to continue"
    }
    
    func resumeGame() {
        gamePaused = false
        clickRecognizer.numberOfClicksRequired = 2
        mapView.removeAnnotations(mapView.annotations)
        nextCity()
    }
    
    func computeScoreFor(locationA: CLLocationCoordinate2D, locationB: CLLocationCoordinate2D) -> Int {
        let meters = MKMetersBetweenMapPoints(MKMapPointForCoordinate(locationA), MKMapPointForCoordinate(locationB))
        var score = 0
        score = 500 - Int(meters / 1000)
        
        return max(0, score)
    }
    
    func mapClicked(_ sender: NSGestureRecognizer) {
        guard !gamePaused else { resumeGame(); return }
        let location = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
        let correctLocation = cities[currentCity].location
        let thisScore = computeScoreFor(locationA: location, locationB: correctLocation)
        var color: NSColor!
        switch thisScore {
        case let x where x < 100:
            color = NSColor.red
        case let x where x < 350:
            color = NSColor.yellow
        default:
            color = NSColor.green
        }
        
        let guessPin = Pin(title: "Score: \(thisScore)", subtitle: nil, coordinate: location, color: color)
        mapView.addAnnotation(guessPin)
        mapView.selectAnnotation(guessPin, animated: true)
        
        let correctPin = Pin(title: "", subtitle: nil, coordinate: correctLocation, color: NSColor.white)
        mapView.addAnnotation(correctPin)
        
        score += thisScore
        
        pauseGame()
    }
    
    func nextCity() {
        currentCity += 1
        if currentCity < cities.count {
            questionLabel.stringValue = "Where is \(cities[currentCity].name)?"
        }
        else {
            let alert = NSAlert()
            alert.messageText = "Game over! Your score is \(score)"
            alert.addButton(withTitle: "New game")
            alert.addButton(withTitle: "Quit")
            if alert.runModal() == NSAlertFirstButtonReturn {
                startGame()
            }
            else {
                NSApplication.shared().terminate(self)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let pin = annotation as? Pin else { return nil }
        let identifier = "guess"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: pin, reuseIdentifier: identifier)
        } else {
            pinView!.annotation = pin
        }
        pinView?.canShowCallout = true
        pinView!.pinTintColor = pin.color
        
        return pinView
    }


}

