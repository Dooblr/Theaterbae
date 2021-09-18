//
//  ContentModel.swift
//  FlickFind
//
//  Created by admin on 9/12/21.
//

import Foundation


class ContentModel: ObservableObject {

    let headers = [
        "x-rapidapi-host": "imdb8.p.rapidapi.com",
        "x-rapidapi-key": "c5e55581dcmsh765de9634a8dff2p144394jsn3456c03b3062"
    ]
    
    @Published var searchContent:IMDBTitle?
    @Published var imageData:Data?
    
    // ID of the movie the user entered
    var searchId:String?
    // Cast of the movie user entered
    var searchCast:[String]?
    
    // New content from searched name
    @Published var newContent:KnownForTitle?
    
    // array to hold already shown content
    var shownContentIds = [String]()
    
    // MARK: - IMDB API Methods
    
    // Initial user-inputted search for an IMDB title, publishes the object, and adds id to shownContentIds
    func getIMDBTitle (title:String) {
        
        // remove whitespace and url incompatible characters
        let titleNoWhitespace = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let request = NSMutableURLRequest(url: NSURL(string: "https://imdb8.p.rapidapi.com/auto-complete?q=\(titleNoWhitespace)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
//                let httpResponse = response as? HTTPURLResponse
//                print(httpResponse)
                do {
                    let result = try JSONDecoder().decode(IMDBSearch.self, from: data!)
                    
                    DispatchQueue.main.async {
                        
                        // set selected content to returned result
                        self.searchContent = result.d.first
                        
                        // set the displayed image
                        self.setImageDataFromUrl(url: self.searchContent?.image?.imageUrl ?? "")
                        
                        // set searchId
//                        self.searchId = self.searchContent?.id
                        
                        // add searchId to shown content
                        self.shownContentIds.append((self.searchContent?.id)!)
                    }
                } catch {
                    print(error)
                }
            }
        })

        dataTask.resume()
        
    }
    
    func setImageDataFromUrl(url:String) {
        
        if let url = URL(string: url) {
            let session = URLSession.shared
            let dataTask = session.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    self.imageData = data!
                }
            }
            dataTask.resume()
        }
    }
    
    func getNewRecommendation() {
        
        // get the cast from the searched movie's ID
        self.getCastFromId(IMDBId: (self.searchContent?.id)!)
        
    }
    
    func getCastFromId(IMDBId: String) {

        let request = NSMutableURLRequest(url: NSURL(string: "https://imdb8.p.rapidapi.com/title/get-top-cast?tconst=\(IMDBId)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                do {
                    let result = try JSONDecoder().decode([String].self, from: data!)
                    self.searchCast = result
                    self.getTopContentFromFirstCast()
                } catch {
                    print(error)
                }
            }
        })
        dataTask.resume()
    }
    
    func getTopContentFromFirstCast() {
        
        // gets the first member of the cast
        let firstCast = self.searchCast?.first
        
        // format to IMDB ID name code
        let firstCastIMDBId = firstCast!.dropFirst(6).dropLast(1)
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://imdb8.p.rapidapi.com/actors/get-known-for?nconst=\(firstCastIMDBId)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            do {
                let result = try JSONDecoder().decode([KnownForSearch].self, from: data!)
                DispatchQueue.main.async {
                    
                    // if the first result is the same as the searched result, go to the second item
//                    let newId = result.first?.id!.dropFirst(7).dropLast(1)
                    
                    // loop through known for titles
                    for knownForTitle in result {
                        let slicedTitle = knownForTitle.title?.id?.dropFirst(7).dropLast(1)
                        if self.shownContentIds.contains((slicedTitle.map(String.init)!)) != true {
                            self.newContent = knownForTitle.title
                            self.shownContentIds.append(slicedTitle.map(String.init)!)
                            break
                        }
                    }
                    
                    // set the displayed image data to new content image
                    self.setImageDataFromUrl(url: self.newContent?.image?.url ?? "")
                }
            } catch {
                print(error)
            }
        })

        dataTask.resume()
//        return
    }
}
