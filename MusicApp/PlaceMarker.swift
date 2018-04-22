//
//  PlaceMarker.swift
//  MusicApp
//
//  Created by Mikołaj Bujok on 22.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import Foundation
import MapKit

protocol AnnotationChangeDelegate: class {
    func remove(marker: PlaceMarker)
}

class PlaceMarker: NSObject, MKAnnotation {

    let title: String?
    let locationType: String
    let lifeSpan: Int
    let coordinate: CLLocationCoordinate2D

    private var timer: Timer?

    weak var delegate: AnnotationChangeDelegate?

    init(title: String, lifeSpan: Int, locationType: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.lifeSpan = lifeSpan
        self.locationType = locationType
        self.coordinate = coordinate

        super.init()


    }

    var subtitle: String? {
        return locationType
    }

    @objc func selfDestruct() {
        if delegate != nil {
            delegate!.remove(marker: self)
        }
    }

    func startLife(_ delegate: AnnotationChangeDelegate) {
        self.delegate = delegate
        DispatchQueue.main.async {
            self.timer = Timer.init(timeInterval: TimeInterval(self.lifeSpan), target: self, selector: #selector(self.selfDestruct), userInfo: nil, repeats: false)

            print(self.timer?.isValid)
        }
    }
}
