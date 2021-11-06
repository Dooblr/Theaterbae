//
//  Constants.swift
//  FlickFind
//
//  Created by admin on 9/12/21.
//

import Foundation

struct Constants {
    
    static let privateApiKey = ProcessInfo.processInfo.environment["privateApiKey"]
    static let publicApiKey = ProcessInfo.processInfo.environment["publicApiKey"]
    
    // IMDB RapidAPI request headers
    static let rapidApiHost = ProcessInfo.processInfo.environment["x-rapidapi-host"]
    static let rapidApiKey = ProcessInfo.processInfo.environment["x-rapidapi-key"]
    
    static let rapidApiHeaders = ["x-rapidapi-host": rapidApiHost!, "x-rapidapi-key": rapidApiKey!]
    
}
