//
//  RestConnector.swift
//  MusicApp
//
//  Created by Mikołaj Bujok on 21.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

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

//        sendHttpRequest(url: url,
//                        errorHandler: { (error: Error?) in
//                            if error != nil {
//                                errorHandler(error!.localizedDescription)
//                            }
//        },
//                        successHandler: { (response: ResponseModel) in
//                            if response.offset + self.batchSize < response.count {
//                                
//                            }
//
//        })

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

//        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { (data, response, error) in
//            DispatchQueue.global().async {
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
                    } catch {
                        errorHandler(error.localizedDescription)
                    }
                } else {
//                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    errorHandler("No data received")
                }
//            }
        }

        task.resume()
    }

//    func sendHttpRequest<T: Codable>(url: URL, object: T) {
//        let jsonData = Data()
//        let decoder = JSONDecoder()
//        do {
//            let response = try decoder.decode(T.self, from: jsonData)
//
////            succesHandler(response.places)
//        } catch {
////            errorHandler(error.localizedDescription)
//        }
//
//    }

    func sendHttpRequest<T: Codable>(url: URL, errorHandler: @escaping (_ error: Error?) -> Void, successHandler: @escaping (_ object: T) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { data, response, error in

            if error == nil {
                if let jsonData = data {
                    print("jsonData: ", String(data: jsonData, encoding: .utf8) ?? "no body data")
                    let decoder = JSONDecoder()

                    do {
                        let places = try decoder.decode(T.self, from: jsonData)
                        successHandler(places)
                    } catch {
                        errorHandler(error)
                    }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    errorHandler(error)
                }
            }
        }
        task.resume()
    }
//
//    func getPosts(completion: ((Result<ResponseModel>) -> Void)?) {
//        var urlComponents = URLComponents()
//        urlComponents.scheme = "https"
//        urlComponents.host = musicBrainzEndpoint
//        urlComponents.path = "/ws/2/place"
//        urlComponents.queryItems = [URLQueryItem(name: "query", value: "poznań AND begin:[1974 TO *]"),
//        URLQueryItem(name: "limit", value: "1"),
//        URLQueryItem(name: "offset", value: "1")]
////        let userIdItem = URLQueryItem(name: "userId", value: "12")
////        urlComponents.queryItems = [userIdItem]
//        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let config = URLSessionConfiguration.default
//        let session = URLSession(configuration: config)
//        let task = session.dataTask(with: request) { (responseData, response, responseError) in
//            DispatchQueue.main.async {
//                if let error = responseError {
//                    completion?(.failure(error))
//                } else if let jsonData = responseData {
//                    // Now we have jsonData, Data representation of the JSON returned to us
//                    // from our URLRequest...
//
//                    // Create an instance of JSONDecoder to decode the JSON data to our
//                    // Codable struct
//                    print(jsonData)
//                    print("jsonData: ", String(data: jsonData, encoding: .utf8) ?? "no body data")
//                    let decoder = JSONDecoder()
//
//                    do {
//                        // We would use Post.self for JSON representing a single Post
//                        // object, and [Post].self for JSON representing an array of
//                        // Post objects
//                        let posts = try decoder.decode(ResponseModel.self, from: jsonData)
//                        completion?(.success(posts))
//                    } catch {
//                        completion?(.failure(error))
//                    }
//                } else {
//                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
//                    completion?(.failure(error))
//                }
//            }
//        }
//
//        task.resume()
//    }
}
