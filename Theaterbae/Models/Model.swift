//
//  Model.swift
//  Theaterbae
//
//  Created by admin on 9/12/21.
//

import Foundation

struct IMDBSearch: Decodable {
    var d = [IMDBTitle]()
}

class IMDBTitle: Decodable, ObservableObject {
    
    var id: String?
    var image: IMDBImage?
    var title: String?
    var type: String?
    var cast: String?
    var year: Int?
    var yearsRunning: String?
    
    enum CodingKeys:String,CodingKey {
        case id
        case image = "i"
        case title = "l"
        case type = "q"
        case cast = "s"
        case year = "y"
        case yearsRunning = "yr"
    }
}

struct IMDBImage: Decodable {
    
    var height: Int?
    var imageUrl: String?
    var width: Int?
    
    enum CodingKeys: CodingKey {
        case height
        case imageUrl
        case width
    }
}

struct KnownForSearch: Decodable {
    var title :KnownForTitle?
    // summary
    // categories
    // wheretowatch
}

struct KnownForTitle: Decodable {
    var id: String?
    var image: KnownForImage?
    var title: String?
    var titleType: String?
    var year: Int?
}

struct KnownForImage: Decodable {
    var height: Int?
    var id: String?
    var url: String?
    var width: Int
}

struct PlotsSearch: Decodable {
    // id
    // base // general info
    var plots:[Plot]?
}

struct Plot: Decodable {
    // id
    var text:String?
}

// 40 year old virgin IMDBtitlecode: tt0405422
