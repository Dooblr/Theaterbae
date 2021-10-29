//
//  ContentModel.swift
//  FlickFind
//
//  Created by admin on 9/12/21.
//

import Foundation
import CoreData

class DiscoverModel: ObservableObject {

    // Fetch CoreData for filtering recommendations
    init(){
        let dataModel = DataModel()
        // Append every ID in the watchlist/coredata to prevent showing in recommendations
        for entity in dataModel.savedEntities {
            // Convert to IMDB format (e.g. tt0405422)
            let slicedID = entity.id?.dropFirst(7).dropLast(1) ?? ""
            shownContentIds.append("\(slicedID)")
        }
    }

    // MARK: - Search and Recommendation

    // Array of IMDBTitles resulting from the auto-search
    var searchResults:IMDBSearch?

    // Single IMDB title object used to display initial search
    @Published var searchContent:IMDBTitle?

    // Cast of the movie user entered
    var searchCast:[String]?

    // Known for titles set via searchCast - type KnownForSearch is the json entrypoint for [KnownForTitle]
    @Published var knownForContent = [KnownForSearch]()

    // New content from searched name
    @Published var recommendedContent:KnownForTitle?

    // Array to hold content that has been shown already
    var shownContentIds = [String]()

    // Index for scrolling through imdb content results if user says 'Not my content'
    @Published var searchIndex = 0

    // MARK: - Image Data

    // ConfirmSearchResultView image
    @Published var confirmTitleImageData:Data?
    // RecommendationView image
    @Published var recommendationImageData:Data?

    // MARK: - View toggles
    
    // Used to toggle loading view while fetching data
    @Published var isLoading: Bool?

    // MARK: - Alerts

    // Toggle to alert the user when they have reached the end of the IMDB auto-search results
    @Published var autoSearchAlertIsPresented = false

    // Toggle alert for no internet
    @Published var alertNoInternet = false
    
//    @Published var 

    // Alert recommendation view that no more recommendations are available, and return to search view
    @Published var noRecommendationsRemaining = false

    // MARK: - IMDB API Methods
    // TODO: Update data methods to async await

    // Initial user-inputted search for an IMDB title, publishes the object, and adds id to shownContentIds
    func getIMDBTitle (title:String, completion: @escaping () -> Void) {

        // Notify view to display loading screen
        self.isLoading = true

        // remove whitespace and url incompatible characters
        let titleNoWhitespace = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let request = NSMutableURLRequest(url: NSURL(string: "https://imdb8.p.rapidapi.com/auto-complete?q=\(titleNoWhitespace)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = Constants.rapidApiHeaders

        let session = URLSession.shared
        session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
                DispatchQueue.main.async {
                    self.alertNoInternet = true
                }
            } else {
                // Monitor HTTP response including usage reports
                // let httpResponse = response as? HTTPURLResponse
                // print(httpResponse)
                do {
                    let result = try JSONDecoder().decode(IMDBSearch.self, from: data!)
                    self.searchResults = result
                    completion()
                } catch {
                    print(error)
                }
            }
        }).resume()
    }

    func showNewSearchResult() {
        DispatchQueue.main.async {

            // set selected content to returned result
            if self.searchIndex < self.searchResults!.d.count {
                self.searchContent = self.searchResults!.d[self.searchIndex]
            } else {
                // There are no other results
            }

            // set the displayed image
            self.setImageDataFromUrl(url: self.searchContent?.image?.imageUrl ?? "", forView: "ConfirmSearchResultView")

            // add searchId to shown content
            self.shownContentIds.append((self.searchContent?.id)!)

            // Inform views that loading has completed
            self.isLoading = false
        }
    }

    // Takes a string and a view name and sets the
    func setImageDataFromUrl(url:String, forView:String) {

        if let url = URL(string: url) {
            let session = URLSession.shared
            let dataTask = session.dataTask(with: url) { data, response, error in

                // Sets the image data based on the view name passed in
                DispatchQueue.main.async {
                    switch forView{
                    case "ConfirmSearchResultView":
                        self.confirmTitleImageData = data ?? Data()
                    case "RecommendationView":
                        self.recommendationImageData = data ?? Data()
                    default:
                        break
                    }
                }
            }
            dataTask.resume()
        }
    }

    // Takes an IMDB ID and gets the search cast, then gets content from said cast
    func getCastFromId(IMDBId: String, completion: @escaping () -> Void) {

        // Change view to loading screen
        self.isLoading = true

        // Clear previously set recommended image data
        self.recommendationImageData = Data()

        // Runs IMDB's get-top-cast call, and on completion gets the content from the cast
        let request = NSMutableURLRequest(url: NSURL(string: "https://imdb8.p.rapidapi.com/title/get-top-cast?tconst=\(IMDBId)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = Constants.rapidApiHeaders

        let session = URLSession.shared
        session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                do {
                    let result = try JSONDecoder().decode([String].self, from: data!)
                    self.searchCast = result
                    completion()
                } catch {
                    print(error)
                }
            }
        }).resume()
    }

    // Uses the search cast and gets their "Known for" content
    func getKnownForContentFromCast(completion: @escaping () -> Void) {

        // Dispatch group to call completion after all API calls have finished
        let knownForDispatchGroup = DispatchGroup()
        for index in 0...2 {
            
            // Notify dispatch that api call has started
            knownForDispatchGroup.enter()
            // format to IMDB ID name code
            let ImdbCastID = self.searchCast![index].dropFirst(6).dropLast(1)

            let request = NSMutableURLRequest(url: NSURL(string: "https://imdb8.p.rapidapi.com/actors/get-known-for?nconst=\(ImdbCastID)")! as URL,
                                                    cachePolicy: .useProtocolCachePolicy,
                                                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = Constants.rapidApiHeaders

            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                do {
                    let result = try JSONDecoder().decode([KnownForSearch].self, from: data!)
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
        
        // Run completion after all API calls have finished
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
                    self.shownContentIds.append(imdbTitleIdStripped.map(String.init)!)

                    break
                }
                
                // increment loop index
                index += 1
            }
            
            // set the displayed image data to new content image
            self.setImageDataFromUrl(url: self.recommendedContent?.image?.url ?? "", forView: "RecommendationView")

            // Notify view to remove loading view
            self.isLoading = false
            
            // If index has exceeded knownforcontent, throw error and navigate back to search
            if index == self.knownForContent.count {
                self.noRecommendationsRemaining = true
            }
        }
    }
}
