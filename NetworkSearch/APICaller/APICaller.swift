//
//  APICaller.swift
//  TestStoryboard
//
//  Created by Илья Мишин on 29.05.2023.
//

import Foundation
import Alamofire

class APICaller {
    
    static let shared = APICaller()
    
    private let accessKey = "4c9fbfbbd92c17a2e95081cec370b4511659666240eb4db9416c40c641ee843b"
    private let baseUrl = "https://api.unsplash.com"
    private let itemsPerPage = 30
    
    private init() {}
    
    // Fetches pictures from the Unsplash API
    func getPictures(with query: String? = nil, page: Int, completion: @escaping (Result<[Results], Error>) -> Void) {
        let endpoint: String
        var parameters: Parameters = [
            "page": page,
            "per_page": itemsPerPage,
            "client_id": accessKey
        ]
        
        // Determines the endpoint and sets the parameters based on the query
        if let query = query {
            endpoint = "/search/photos"
            parameters["query"] = query
        } else {
            endpoint = "/photos/"
        }
        
        // Constructs the URL and sends a GET request using Alamofire
        let urlString = "\(baseUrl)\(endpoint)"
        AF.request(urlString, method: .get, parameters: parameters).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    // Decodes the response data into either Response or [Results] objects
                    if query != nil {
                        let fetchedResult = try JSONDecoder().decode(Response.self, from: data)
                        completion(.success(fetchedResult.results))
                    } else {
                        let fetchedResult = try JSONDecoder().decode([Results].self, from: data)
                        completion(.success(fetchedResult))
                    }
                } catch {
                    print("ERROR: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("WARNING: Error occurred during the API request.")
                completion(.failure(error))
            }
        }
    }
}
