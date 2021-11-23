//
//  Helpers.swift
//  Theaterbae
//
//  Created by admin on 11/15/21.
//

import Foundation

struct Helpers {
    // Takes a url string and asynchronously returns raw data
    static func getImageDataFromUrl(url:String) async -> Data  {

        if let url = URL(string: url) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                return data
            } catch {
                print(error)
            }
        }
        
        return Data()
    }
}


