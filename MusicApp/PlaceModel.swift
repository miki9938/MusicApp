//
//  PlaceModel.swift
//  MusicApp
//
//  Created by Mikołaj Bujok on 21.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import Foundation
//import MapKit

struct PlaceModel: Codable {

    var id: String
    var type: String? = "Other"
    var name: String?

    var coordinates: Coords?
    var lifeSpan: LifeSpan

//    var score: Int
//    var address: String
//    var area: AreaModel
//    var alias: AliasModel

    enum CodingKeys: String, CodingKey {
        case lifeSpan = "life-span"
        case id, type, name, coordinates
    }
}

//struct LifeSpan: Codable {
//    var begin: Date?
////    var end: Date?
////    var ended: Bool?
//
//    init(begin: Date?, end: Date?, ended: Bool?) {
//        self.begin = begin
////        self.end = end
////        self.ended = ended
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//
//        let beginString = try container.decode(String.self, forKey: .begin)
//
////        let beginDate = dateFormatter.date(from: beginString)
//
//        guard let beginDate = dateFormatter.date(from: beginString) else {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy"
//
//            let smallDate = dateFormatter.date(from: beginString)
//
//            self.init(begin: smallDate, end: nil, ended: nil)
//            return
//        }
//
////        let endString = try container.decode(String.self, forKey: .end)
////        let endDate = dateFormatter.date(from: endString)
////
////        let endedString = try container.decode(String.self, forKey: .ended)
////        var endedBool: Bool? = nil
////        if endedString != "null" {
////            endedBool = Bool(endedString)!
////        }
//
//        self.init(begin: beginDate, end: nil, ended: nil)
//    }
//
//}

struct LifeSpan: Codable {
    var beginYear: Int
//    var ended: Bool

    init(beginYear: Int) {
        self.beginYear = beginYear
//        self.ended = ended
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let beginString = try container.decode(String.self, forKey: .beginYear)

        guard let beginYear = Int(beginString.prefix(4)) else {
            self.init(beginYear: 0)
            return
        }

//        let endedString = try container.decode(String.self, forKey: .ended)
//        var ended: Bool = false
//        if endedString != "null" {
//            ended = Bool(endedString)!
//        }

        self.init(beginYear: beginYear - 1990)
    }

    enum CodingKeys: String, CodingKey {
        case beginYear = "begin"
    }
}

struct LifeSpan1: Codable {
    var begin: Date?
    var end: Date?
    var ended: Bool?
    var year: Int

    init(begin: Date?, end: Date?, ended: Bool?) {
        self.begin = begin
        self.end = end
        self.ended = ended

        let calendar = Calendar.current
        self.year = calendar.component(.year, from: begin!)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let beginString = try container.decode(String.self, forKey: .begin)

        //        let beginDate = dateFormatter.date(from: beginString)

        guard let beginDate = dateFormatter.date(from: beginString) else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"

            let smallDate = dateFormatter.date(from: beginString)

            self.init(begin: smallDate, end: nil, ended: nil)
            return
        }

        //        let endString = try container.decode(String.self, forKey: .end)
        //        let endDate = dateFormatter.date(from: endString)
        //
        //        let endedString = try container.decode(String.self, forKey: .ended)
        //        var endedBool: Bool? = nil
        //        if endedString != "null" {
        //            endedBool = Bool(endedString)!
        //        }

        self.init(begin: beginDate, end: nil, ended: nil)
    }

}

struct AreaModel: Codable {
    var id: String
    var name: String
    var sortName: String
}

struct Coords: Codable {
    var latitude: String
    var longitude: String
}

//struct Coords: Codable {
//    var latitude: Double
//    var longitude: Double
//
//    init(latitude: Double, longitude: Double) {
//        self.latitude = latitude
//        self.longitude = longitude
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        let latString =
//
//
//            self.init(latitude: <#T##Double#>, longitude: <#T##Double#>)
//    }
//}

struct AliasModel: Codable {

}

enum PlaceTypeEnum {
    case Studio,
    Venue,
    Stadium,
    IndoorArena,
    ReligiousBuilding,
    Other
}
