//
//  APIResponseModel.swift
//  TestStoryboard
//
//  Created by Илья Мишин on 29.05.2023.
//

import Foundation

struct Response: Codable {
    let results: [Results]
}

struct Results: Codable {
    let id: String
    let urls: ResultURL
}

struct ResultURL: Codable {
    let small: String
}
