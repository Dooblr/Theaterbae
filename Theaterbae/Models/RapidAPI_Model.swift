//
//  Model.swift
//  Theaterbae
//
//  Created by admin on 9/12/21.
//

import Foundation

struct KnownForSearch: Decodable {
    var title :KnownForTitle
    var imdbRating: Double
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
    // inserted in DiscoverModel.getKnownForContent:
    var imageData: Data?
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
