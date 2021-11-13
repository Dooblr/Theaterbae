//
//  IMDB_Model.swift
//  Theaterbae
//
//  Created by admin on 11/12/21.
//

import Foundation


// https://imdb-api.com/en/API/SearchAll/k_a1i0usrw/the_office
struct SearchAll: Decodable {
//    var searchTipe: String
//    var expression: String
    var results: [SearchResult]
}

struct SearchResult: Decodable {
    var id: String
    var resultType: String
    var image: String // image url
    var title: String
    var description: String
}

// https://imdb-api.com/en/API/Title/k_a1i0usrw/tt0386676/FullActor,FullCast,Posters,Images,Trailer,Ratings,
struct Title: Decodable {
    var id: String?
    var title: String?
    var type: String?
    var year: String?
    var image: String?
    var runtimeMins: String?
    var runtimeStr: String?
    var plot: String?
    var directors: String?
//    var directorList: [Director]?
    var writers: String?
//    var writerList: [String]?
    var stars: String?
    var starList: [Actor]?
    // TODO: Use directors, writers, and producers below
//    var fullCast // produces results for directors and writers
    var genres: String?
    var countries: String?
    var languages: String?
    var contentRating: String?
    var imDbRating: String?
    var imDbRatingVotes: String?
    var metacriticRating: String?
//    var ratings // includes imdb,metacritic,rottentomatoes, etc.
    var images: ImdbImage?
    var trailer: Trailer?
    var similars: [Similars]?
}

struct Actor: Decodable {
    var id: String
    var name: String
}

struct ImdbImage: Decodable {
    var imDbId: String
    var items: [ImageItem]
}

struct ImageItem: Decodable {
    var title: String
    var image: String // image URL
}

struct Trailer: Decodable {
    var videoId: String
    var videoTitle: String
    var thumbnailUrl: String
    var link: String
    var linkEmbed: String
}

struct Similars: Decodable {
    var id: String
    var title: String
    var year: String
    var image: String
    var plot: String
    var directors: String
    var stars: String
    var genres: String
    var imDbRating: String
}

struct TvSeriesInfo: Decodable {
    var creators: String
    var creatorList: [Creator]
    var seasons: [String]
}

struct Creator: Decodable {
    var id: String
    var name: String
}
