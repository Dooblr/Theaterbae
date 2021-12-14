//
//  Helpers.swift
//  Theaterbae
//
//  Created by admin on 11/15/21.
//

import Foundation

struct Helpers {
    
    // Asynchronously takes a url string and returns raw data
    static func getImageDataFromUrl(url:String) async -> Data  {

        if let url = URL(string: url) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                // Success
                return data
            } catch {
                print(error)
            }
        }
        
        // Returns empty data if fetching data fails
        return Data()
    }
}


