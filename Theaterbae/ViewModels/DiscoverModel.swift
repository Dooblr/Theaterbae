//
//  ContentModel.swift
//  Theaterbae
//
//  Created by admin on 9/12/21.
//

import Foundation
import CoreData
import SwiftUI

class DiscoverModel: ObservableObject {

    init() {
        // Fetch CoreData for filtering recommendations
        let dataModel = DataModel()
        // Prevent showing in recommendations by appending every ID in the watchlist/coredata to shownContentIDs
        for entity in dataModel.savedEntities {
            // Convert to IMDB format (e.g. /title/tt0405422/ to tt0405422)
            shownContentIds.append("\(entity.id!)")
        }
    }
    
    // MARK: - Search

    // Array of IMDB titles resulting from IMDB Search All
    var imdbSearchResults:[SearchResult] = []

    // Single IMDB title object published for use in confirmSeachView
    @Published var imdbSearchContent:SearchResult?

    // Stores an array of cast members
    var searchCast:[String] = []
    
    
    // MARK: - Recommendation

    // Known for titles set via searchCast - type KnownForSearch is the json entrypoint for [KnownForTitle]
    var knownForContent:[KnownForTitle] = []

    // New content from searched name
    @Published var recommendedContent:KnownForTitle?

    // Array to hold content that has been shown already
    var shownContentIds = [String]()

    // Index for scrolling through imdb content results if user says 'Not the right content I'm searching for' in ConfirmSearchResultView
    @Published var searchIndex = 0
    
    // Number of actors from which to pull KnownForContent (zero-based so total = actorsToQuery + 1)
    let actorsToQuery = 0

    
    // MARK: - View toggles
    
    // Toggles loading views while fetching data
    @Published var isLoading = true

    
    // MARK: - Alerts

    // Toggle to alert the user when they have reached the end of the IMDB auto-search results
    @Published var alertNoSearchResultsRemaining = false
    // Toggle alert for no internet
    @Published var alertNoInternet = false
    // Alert recommendation view that no more recommendations are available, and navigate back to search view
    @Published var noRecommendationsRemaining = false

    
    // MARK: - IMDB API Methods
    
    // Takes user input from SearchView and populates a list of search results self.imdbSearchResults
    func searchAll(title:String) async {
        
        // Clear any previous search results
        self.imdbSearchResults = []
        
        let titleNoWhitespace = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var request = URLRequest(url: URL(string: "https://imdb-api.com/en/API/SearchAll/\(API_Keys.imdbApiKey)/\(titleNoWhitespace)")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request as URLRequest)
            do {
                let result = try JSONDecoder().decode(SearchAll.self, from: data)
//                self.imdbSearchResults = result.results
                // Remove any non-titles from results
                for item in result.results {
                    if item.resultType == "Title" {
                        self.imdbSearchResults.append(item)
                    }
                }
            } catch {
                print("failed to parse JSON. Error: ")
                print(error)
            }
        } catch {
            print("failed to search. Error: ")
            print(error)
            DispatchQueue.main.async {
                self.alertNoInternet = true
            }
        }
    }
    
    func showNewImdbSearchResult() {
        DispatchQueue.main.async {

            // set selected content to returned result
            if self.searchIndex < self.imdbSearchResults.count {
                self.imdbSearchContent = self.imdbSearchResults[self.searchIndex]
            } else {
                // Alert view that there are no other results
                self.alertNoSearchResultsRemaining = true
            }

            // add searchId to shown content
            self.shownContentIds.append((self.imdbSearchContent?.id)!)

            // Inform views that loading has completed
            self.isLoading = false
        }
    }
    
    // Takes an IMDB ID and gets the full list of information for that title. Currently only using to set cast data
    func getFullTitleInfo(id: String) async -> Title{
        
        // Ensure that ID is formatted correctly: tt0000000
        var strippedID = id
        
        if strippedID.count > 9 {
            strippedID = String(id.dropFirst(7).dropLast(1))
        }
        
        var request = URLRequest(url: URL(string: "https://imdb-api.com/en/API/Title/\(API_Keys.imdbApiKey)/\(strippedID)/FullActor,FullCast,Posters,Images,Trailer,Ratings,")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request as URLRequest)
            print(data)
            do {
                let result = try JSONDecoder().decode(Title.self, from: data)
                return result
            } catch {
                print("failed to parse JSON. Error: ")
                print(error)
            }
        } catch {
            print("failed to get full title. Error: ")
            print(error)
        }
        // returns empty title if result failed
        return Title()
    }
    
    // Takes a title and sets the search cast
    func setCast(title:Title) {
        for star in title.starList! {
            self.searchCast.append(star.id)
        }
    }
    
    
    // MARK: - RapidAPI IMDB Methods
    
    func getKnownForContent() async {
        
        // Inform view that loading has begun
        self.isLoading = true
        
        // Get the top 3 actors/stars' top movies & tv (actorsToQuery == 3)
        for index in 0...self.actorsToQuery {
            
            // Use the published searchCast to select the indexed IMDB ID
            let ImdbCastID = self.searchCast[index]

            // RapidAPI IMDB get-known-for endpoint
            var request = URLRequest(url: URL(string: "https://imdb8.p.rapidapi.com/actors/get-known-for?nconst=\(ImdbCastID)")!,
                                                    cachePolicy: .useProtocolCachePolicy,
                                                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = API_Keys.rapidApiHeaders

            // Assume connection is successful
            let (data, _) = try! await URLSession.shared.data(for: request as URLRequest)
            do {
                // returns an array of KnownForSearch. title has the main payload
                let result = try JSONDecoder().decode([KnownForSearch].self, from: data)
                for searchResult in result {
                    let title = searchResult.title
                    self.knownForContent.append(title)
                }
            } catch {
                print("failed to parse JSON. Error: ")
                print(error)
            }
        }
    }
    
//    func getKnownForImageData() async {
//        for (index, title) in self.knownForContent.enumerated() {
//            self.knownForContent[index].imageData = await Helpers.getImageDataFromUrl(url: (title.image?.url)!)
//        }
//        print("loaded images")
//    }

    func nextRecommendedContent() {
        
        DispatchQueue.main.async {

            // loop through known for titles
            var index = 0
            for knownForTitle in self.knownForContent {
                
                // IMDB format
                let imdbTitleIdStripped = knownForTitle.id!.dropFirst(7).dropLast(1)
                let imdbTitleId = String(imdbTitleIdStripped)

                // If the ID has not already been shown to the user, continue
                if !self.shownContentIds.contains(imdbTitleId) {

                    // Set the observed recommended content
                    self.recommendedContent = knownForTitle
                    
//                    self.recommendationImageData = knownForTitle.imageData
                    
                    // Add recommended content to the already shown array
                    self.shownContentIds.append(imdbTitleId)

                    break
                }
                
                // increment loop
                index += 1
            }
            
            // If index has exceeded knownforcontent, throw error and navigate back to search
            if index == self.knownForContent.count {
                self.noRecommendationsRemaining = true
            }
        }
    }
    
    // Return to previous content
    func revertRecommendedContent() {
        
        // Remove 2 because recommendationview will reload and setRecommendedContent will re-add the previous content we're trying to return to
        self.shownContentIds.removeLast(2)
        
        let searchId = (self.imdbSearchContent?.id)!
        
        // If the original search has been removed, re-add it to showncontentIDs
        if !self.shownContentIds.contains(searchId) {
            self.shownContentIds.append(searchId)
        }
        self.nextRecommendedContent()
    }
    
    static func getContentPlot(imdbContentID:String) async -> String {
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://imdb8.p.rapidapi.com/title/get-plots?tconst=\(imdbContentID)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = API_Keys.rapidApiHeaders
        
        let (data, _) = try! await URLSession.shared.data(for: request as URLRequest)
        
        let result = try! JSONDecoder().decode(PlotsSearch.self, from: data)
        return (result.plots?.first?.text)!
    }
    
}
