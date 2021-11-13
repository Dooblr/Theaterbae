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

    // Fetch CoreData for filtering recommendations
    init() {
        let dataModel = DataModel()
        // Prevent showing in recommendations by appending every ID in the watchlist/coredata to shownContentIDs
        for entity in dataModel.savedEntities {
            // Convert to IMDB format (e.g. /title/tt0405422/ to tt0405422)
            shownContentIds.append("\(entity.id!)")
        }
    }

    // MARK: - Search

    // Array of IMDBTitles resulting from the auto-search
    var searchResults:IMDBSearch?
    var imdbSearchResults:[SearchResult]?

    // Single IMDB title object used to display initial search
    @Published var searchContent:IMDBTitle?
    @Published var imdbSearchContent:SearchResult?

    // Cast of the movie user entered
    var searchCast:[String] = []
    
    // MARK: - Recommendation

    // Known for titles set via searchCast - type KnownForSearch is the json entrypoint for [KnownForTitle]
    @Published var knownForContent:[KnownForSearch] = []

    // New content from searched name
    @Published var recommendedContent:KnownForTitle?

    // Array to hold content that has been shown already
    var shownContentIds = [String]()

    // Index for scrolling through imdb content results if user says 'Not the right content I'm searching for' in ConfirmSearchResultView
    @Published var searchIndex = 0
    
    // Number of actors from which to pull KnownForContent (zero-based so total = actorsToQuery + 1)
    let actorsToQuery = 2

    // MARK: - Image Data

    // ConfirmSearchResultView image
    @Published var confirmTitleImageData:Data?
    // RecommendationView image
    @Published var recommendationImageData:Data?

    // MARK: - View toggles
    
    // Toggles loading views while fetching data
    @Published var isLoading: Bool?

    // MARK: - Alerts

    // Toggle to alert the user when they have reached the end of the IMDB auto-search results
    @Published var autoSearchAlertIsPresented = false
    // Toggle alert for no internet
    @Published var alertNoInternet = false
    // Alert recommendation view that no more recommendations are available, and navigate back to search view
    @Published var noRecommendationsRemaining = false

    // MARK: - IMDB API Methods
    
    // Takes user input from SearchView
    func searchAll(title:String) async {
        let titleNoWhitespace = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var request = URLRequest(url: URL(string: "https://imdb-api.com/en/API/SearchAll/\(Constants.imdbApiKey ?? "")/\(titleNoWhitespace)")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request as URLRequest)
            do {
                let result = try JSONDecoder().decode(SearchAll.self, from: data)
                self.imdbSearchResults = result.results
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
            if self.searchIndex < self.imdbSearchResults!.count {
                self.imdbSearchContent = self.imdbSearchResults![self.searchIndex]
            } else {
                // There are no other results
            }

            // set the displayed image
            Task {
                await self.setImageDataFromUrl(url: self.imdbSearchContent!.image, forView: "ConfirmSearchResultView")
            }

            // add searchId to shown content
            self.shownContentIds.append((self.imdbSearchContent?.id)!)

            // Inform views that loading has completed
            self.isLoading = false
        }
    }
    
    // Takes a string and a view name and sets the image
    func setImageDataFromUrl(url:String, forView:String) async {
        
        self.isLoading = true

        if let url = URL(string: url) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // Sets the image data based on the view name passed in
                DispatchQueue.main.async {
                    switch forView{
                    case "ConfirmSearchResultView":
                        self.confirmTitleImageData = data
                    case "RecommendationView":
                        self.recommendationImageData = data
                    default:
                        break
                    }
                    self.isLoading = false
                }
            } catch {
                print(error)
            }
        }
    }
    
    // Takes an IMDB ID and gets the full list of information for that title. Currently only using to set cast data
    func getFullTitleInfo(id: String) async {
        
        var request = URLRequest(url: URL(string: "https://imdb-api.com/en/API/Title/\(Constants.imdbApiKey ?? "")/\(id)/FullActor,FullCast,Posters,Images,Trailer,Ratings,")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request as URLRequest)
            do {
                let result = try JSONDecoder().decode(Title.self, from: data)
                for star in result.starList! {
                    self.searchCast.append(star.id)
                }
            } catch {
                print("failed to parse JSON. Error: ")
                print(error)
            }
        } catch {
            print("failed to get full title. Error: ")
            print(error)
        }
    }
    
    // MARK: - RapidAPI IMDB Methods

    // Takes an IMDB ID and gets the search cast
//    func getCastFromId(IMDBId: String, completion: @escaping () -> Void) {
//
//        // Change view to loading screen
//        self.isLoading = true
//
//        // Clear previously set recommended image data
//        self.recommendationImageData = Data()
//
//        // Runs IMDB's get-top-cast call, and on completion gets the content from the cast
//        let request = NSMutableURLRequest(url: NSURL(string: "https://imdb8.p.rapidapi.com/title/get-top-cast?tconst=\(IMDBId)")! as URL,
//                                                cachePolicy: .useProtocolCachePolicy,
//                                            timeoutInterval: 10.0)
//            request.httpMethod = "GET"
//            request.allHTTPHeaderFields = Constants.rapidApiHeaders
//
//        let session = URLSession.shared
//        session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//            if (error != nil) {
//                print(error!)
//            } else {
//                do {
//                    let result = try JSONDecoder().decode([String].self, from: data!)
//                    self.searchCast = result
//                    completion()
//                } catch {
//                    print(error)
//                }
//            }
//        }).resume()
//    }

    // After search cast has been set, this gets their "Known for" content and sets it to self.knownForContent
    func getKnownForContentFromCast(completion: @escaping () -> Void) {

        // Dispatch group to call completion after all API calls have finished
        let knownForDispatchGroup = DispatchGroup()
        for index in 0...self.actorsToQuery {
            
            // Notify dispatch that api call has started
            knownForDispatchGroup.enter()
            
            // format to IMDB ID name code
            let ImdbCastID = self.searchCast[index]

            let request = NSMutableURLRequest(url: NSURL(string: "https://imdb8.p.rapidapi.com/actors/get-known-for?nconst=\(ImdbCastID)")! as URL,
                                                    cachePolicy: .useProtocolCachePolicy,
                                                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = Constants.rapidApiHeaders

            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                do {
                    let result = try JSONDecoder().decode([KnownForSearch].self, from: data ?? Data())
                    for searchResult in result {
                        DispatchQueue.main.async {
                            self.knownForContent.append(searchResult)
                        }
                    }
                    // Notify dispatch that API call has finished
                    knownForDispatchGroup.leave()
                } catch {
                    print(error)
                }
            })
            dataTask.resume()
        }
        
        // After all API calls have finished, run completion function
        knownForDispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    func setRecommendedContent() {
        
        DispatchQueue.main.async {

            // loop through known for titles
            var index = 0
            for knownForTitle in self.knownForContent {
                
                // IMDB format
                let imdbTitleIdStripped = knownForTitle.title?.id?.dropFirst(7).dropLast(1)
                let imdbTitleId = imdbTitleIdStripped.map(String.init)!

                // If the ID has not already been shown to the user, continue
                if !self.shownContentIds.contains(imdbTitleId) {

                    // Set the observed recommended content
                    // knownForTitle is a single item in the list of results from an IMDB content cast ID
                    self.recommendedContent = knownForTitle.title
                    
                    // Add recommended content to the already shown array
                    self.shownContentIds.append(imdbTitleId)

                    break
                }
                
                // increment loop index
                index += 1
            }
            
            // set the displayed image data to new content image
            Task {
                await self.setImageDataFromUrl(url: self.recommendedContent?.image?.url ?? "", forView: "RecommendationView")
                
                // Notify view to remove loading view
                self.isLoading = false
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
        self.setRecommendedContent()
    }
    
    static func getContentPlot(imdbContentID:String) async -> String {
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://imdb8.p.rapidapi.com/title/get-plots?tconst=\(imdbContentID)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = Constants.rapidApiHeaders
        
        let (data, _) = try! await URLSession.shared.data(for: request as URLRequest)
        
        let result = try! JSONDecoder().decode(PlotsSearch.self, from: data)
        return (result.plots?.first?.text)!
    }
    
}
