//
//  RecommendationView.swift
//  Theaterbae
//
//  Created by admin on 9/15/21.
//

import SwiftUI

struct RecommendationView: View {
    
    // Access to viewmodels
    @EnvironmentObject var discoverModel:DiscoverModel
    @EnvironmentObject var dataModel:DataModel
    
    // Alerts
    @State var addedToWatchlistAlertIsPresented = false
    
    // Toggle for navigating back to SearchView
    @State var showSearchView = false
    
    // Show more sheet toggle
    @State var isShowingSheet = false
    
    @State var sheetTitle:Title?
    
    var body: some View {
        
        VStack{
            
            if discoverModel.isLoading == false {
                
                // Image
                AsyncImage(url: URL(string: discoverModel.recommendedContent?.image?.url ?? ""))
                    { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                } placeholder: {
                    ProgressView()
//                    Image(systemName: "photo")
//                        .resizable()
//                        .foregroundColor(.gray)
//                        .scaledToFit()
                }
                .shadow(color: .gray, radius: 10, x: 0, y: 10)
                .onTapGesture {
                    self.isShowingSheet = true
                    Task{
                        // Gets extended info from currently displayed recommended content
                        sheetTitle = await discoverModel.getFullTitleInfo(id: (discoverModel.recommendedContent?.id)!)
                    }
                }
                // MARK: - TODO: Sheet View for more info
//                .sheet(isPresented: $isShowingSheet) {
//                    // on dismiss
//                    self.isShowingSheet = false
//                } content: {
//                    RecommendationSheetView(sheetTitle: sheetTitle!)
//                }
                
                // Title
                Text(discoverModel.recommendedContent?.title ?? "")
                    .font(.title)
                
                // Year
                Text(String(discoverModel.recommendedContent?.year ?? 0))
                    .opacity(0.67)
                
                // Buttons
                Group {
                    // Button to provide a new recommendation
                    Button {
                        // Get a new recommendation
                        discoverModel.nextRecommendedContent()
                    } label: {
                        CustomButton(text:"New Recommendation", color:.blue)
                    }
                    
                    HStack {
                       
                        // Revert back button
                        Button {
                            discoverModel.revertRecommendedContent()
                        } label: {
                            CustomButton(text:"Back", color:.yellow)
                        }

                        // Add to coredata watch list Button; loads a new recommendation
                        Button {
                            Task {
                                // Add to coredata, plot is derived from the ID in addcontent
                                await dataModel.addContent(id: discoverModel.recommendedContent?.id ?? "",
                                                     name: discoverModel.recommendedContent?.title ?? "",
                                                     imageUrl: discoverModel.recommendedContent?.image?.url ?? "",
                                                     year: discoverModel.recommendedContent?.year ?? 0)
                                
                                // Get a new recommendation
                                discoverModel.nextRecommendedContent()
                            }
                            
                            // Alert that it has been saved
                            addedToWatchlistAlertIsPresented = true
                        } label: {
                            HStack {
                                CustomButton(text:"Add to watch list", color:.green)
                            }
                        }
                    }
                }
            // Loading view
            } else {
                Text("Loading...")
            }
            
            // Empty navigationlink used to navigate back to SearchView
            NavigationLink(destination: SearchView().navigationBarHidden(true), isActive: $showSearchView) { EmptyView() }
        }
        .padding()
        // Populates list of recommendations from search
        .task {
            let searchId = discoverModel.imdbSearchContent?.id
            if searchId == nil || discoverModel.searchCast.isEmpty {
                // Get title
                let searchTitle = await discoverModel.getFullTitleInfo(id: (searchId)!)
                // Set cast from starlist property in title
                discoverModel.setCast(title: searchTitle)
                // Get knownforcontent from cast
                await discoverModel.getKnownForContent()
                // get the first recommended content
                discoverModel.nextRecommendedContent()
                // Dismiss loading view
                discoverModel.isLoading = false
            }
        }
        
        // MARK: - Alerts
        .alert("Added to Watch List", isPresented: $addedToWatchlistAlertIsPresented) {
            Button {} label: {
                Text("Ok")
            }
        }
        .alert("End of available recommendations", isPresented: $discoverModel.noRecommendationsRemaining) {
            Button {
                // Navigate back to search
                showSearchView = true
            } label: {
                Text("Ok")
            }
        }
    }
}

struct RecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationView()
    }
}
