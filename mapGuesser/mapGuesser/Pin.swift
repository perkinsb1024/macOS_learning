//
//  Pin.swift
//  mapGuesser
//
//  Created by Ben Perkins on 7/24/17.
//  Copyright © 2017 Ben Perkins. All rights reserved.
//

import Cocoa
import MapKit

class Pin: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var color: NSColor
    
    init(title: String, subtitle: String?, coordinate: CLLocationCoordinate2D, color: NSColor = NSColor.green) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.color = color
    }
    
}
