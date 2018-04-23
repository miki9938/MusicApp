//
//  RestConnector.swift
//  MusicApp
//
//  Created by Mikołaj Bujok on 21.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import Foundation

class RestConnector {

    let batchSize = 20
    let minimumYear = 1990

    func getPlaces(search: String, errorHandler: @escaping (_ error: String?) -> Void, succesHandler: @escaping (_ places: [PlaceModel]) -> Void, offset: Int = 0) {

        print("# getPlace: \(search) offset: \(offset)")

        var urlComponents = URLComponents()

        urlComponents.scheme = "https"
        urlComponents.host = "musicbrainz.org"
        urlComponents.path = "/ws/2/place"
        let query: String = String(format: "%@ AND begin:[%@ TO *]", search, String(minimumYear))
        urlComponents.queryItems = [URLQueryItem(name: "query", value: query),
                                    URLQueryItem(name: "limit", value: String(batchSize)),
                                    URLQueryItem(name: "offset", value: String(offset))]

        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }

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

                        if response.offset + self.batchSize < response.count {
                            self.getPlaces(search: search, errorHandler: errorHandler, succesHandler: succesHandler, offset: response.offset + self.batchSize)
                        }
                        succesHandler(response.places)

                    } catch let decoderError {
                        let simpleParse = String(data: jsonData, encoding: .utf8)
                        errorHandler(decoderError.localizedDescription + (simpleParse ?? ""))

                        //when batch size is small and there is a lot of reslt musicbrainz.org throws an error
                        //"Your requests are exceeding the allowable rate limit" -> as an output visible in simpleParse
                    }
                } else {

                    errorHandler("No data received")
                }
            }
        }.resume()
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
