//
//  RestConnector.swift
//  MusicApp
//
//  Created by Mikołaj Bujok on 21.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import Foundation

class RestConnector {

    // Static constants for query
    static let batchSize = 20
    static let minimumYear = 1990

    /**
     Sends a HTTP GET request to  musicbrainz API with a query to find suitable places
     - parameter searchTerm: Place name - main query parameter
     - parameter succesHandler: Success handling closure
     - parameter errorHandler: Error handling closure
     - parameter offset: Offset number (optional), default value = 0
     - parameter places: Array of received places
     - parameter error: String error text
     */
    func getPlaces(searchTerm: String, succesHandler: @escaping (_ places: [PlaceModel]) -> Void, errorHandler: @escaping (_ error: String) -> Void, offset: Int = 0) {

//        var urlComponents = URLComponents()
//
//        urlComponents.scheme = "https"
//        urlComponents.host = "musicbrainz.org"
//        urlComponents.path = "/ws/2/place"
//        let query: String = String(format: "%@ AND begin:[%@ TO *]", searchTerm, String(minimumYear))
//        urlComponents.queryItems = [URLQueryItem(name: "query", value: query),
//                                    URLQueryItem(name: "limit", value: String(batchSize)),
//                                    URLQueryItem(name: "offset", value: String(offset))]

        guard let url = createUrl(searchTerm: searchTerm, offset: offset) else { fatalError("Could not create URL from components") }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request) { data, response, error in

            DispatchQueue.global().async {
                if let error = error {
                    errorHandler(error.localizedDescription)
                } else if let jsonData = data {
                    let decoder = JSONDecoder()

                    do {
                        let response = try decoder.decode(ResponseModel.self, from: jsonData)

                        if response.offset + RestConnector.batchSize < response.count {
                            self.getPlaces(searchTerm: searchTerm, succesHandler: succesHandler, errorHandler: errorHandler, offset: response.offset + RestConnector.batchSize)
                        }
                        succesHandler(response.places)

                    } catch let decoderError {
                        let simpleParse = String(data: jsonData, encoding: .utf8)
                        errorHandler(decoderError.localizedDescription + (simpleParse ?? ""))

                        //  When batch size is small and there is a lot of reslt musicbrainz.org throws an error
                        //  "Your requests are exceeding the allowable rate limit" -> as an output visible in simpleParse
                    }
                } else {
                    errorHandler("No data received")
                }
            }
        }.resume()
    }

    func createUrl(searchTerm: String, offset: Int) -> URL? {

        var urlComponents = URLComponents()

        urlComponents.scheme = "https"
        urlComponents.host = "musicbrainz.org"
        urlComponents.path = "/ws/2/place"
        let query: String = String(format: "%@ AND begin:[%@ TO *]", searchTerm, String(RestConnector.minimumYear))
        urlComponents.queryItems = [URLQueryItem(name: "query", value: query),
                                    URLQueryItem(name: "limit", value: String(RestConnector.batchSize)),
                                    URLQueryItem(name: "offset", value: String(offset))]

        return urlComponents.url
    }

//    func sendHttpRequest<T: Codable>(url: URL, errorHandler: @escaping (_ error: Error?) -> Void, successHandler: @escaping (_ object: T) -> Void) {
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let config = URLSessionConfiguration.default
//        let session = URLSession(configuration: config)
//        let task = session.dataTask(with: request) { data, _, error in
//
//            if error == nil {
//                if let jsonData = data {
//                    print("jsonData: ", String(data: jsonData, encoding: .utf8) ?? "no body data")
//                    let decoder = JSONDecoder()
//
//                    do {
//                        let places = try decoder.decode(T.self, from: jsonData)
//                        successHandler(places)
//                    } catch {
//                        errorHandler(error)
//                    }
//                } else {
//                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data was not retrieved from request"]) as Error
//                    errorHandler(error)
//                }
//            }
//        }
//        task.resume()
//    }
}
