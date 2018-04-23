//
//  PlaceModel.swift
//  MusicApp
//
//  Created by Mikołaj Bujok on 21.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import Foundation

struct PlaceModel: Codable {

    var id: String
    var type: PlaceTypeEnum?
    var name: String?
    var coordinates: Coords?
    var lifeSpan: LifeSpan
    var score: String?
    var address: String?

    enum CodingKeys: String, CodingKey {
        case lifeSpan = "life-span",
        id,
        type,
        name,
        coordinates,
        score,
        address
    }
}

struct LifeSpan: Codable {
    var lifeTime: Int

    init(lifeTime: Int) {
        self.lifeTime = lifeTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let dateString = try container.decode(String.self, forKey: .lifeTime)

        guard let beginYear = Int(dateString.prefix(4)) else {
            self.init(lifeTime: 0)
            return
        }
        self.init(lifeTime: beginYear - 1990)
    }

    enum CodingKeys: String, CodingKey {
        case lifeTime = "begin"
    }
}

struct Coords: Codable {
    var latitude: Double
    var longitude: Double

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let latitudeString = try container.decode(String.self, forKey: .latitude)
        guard let latitude = Double(latitudeString) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Latitude is corrupted"])
        }

        let longitudeString = try container.decode(String.self, forKey: .longitude)
        guard let longitude = Double(longitudeString) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Longitude is corrupted"])
        }

        self.init(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
}

enum PlaceTypeEnum: String, Codable {
    case studio = "Studio",
    venue = "Venue",
    stadium = "Stadium",
    indoorArena = "Indoor arena",
    religiousBuilding = "ReligiousBuilding",
    other = "Other",
    edu = "Educational institution"
}
