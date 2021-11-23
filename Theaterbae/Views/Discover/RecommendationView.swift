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
    
    var body: some View {
        
        VStack{
            
            if discoverModel.isLoading == false {
                
                // Asynchronously load poster image
                AsyncImage(url: URL(string: discoverModel.recommendedContent?.image?.url ?? ""))
                    { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .foregroundColor(.gray)
                        .scaledToFit()
                }
                
                // Title
                Text(discoverModel.recommendedContent?.title ?? "")
                    .font(.title)
                
                // Year
                Text(String(discoverModel.recommendedContent?.year ?? 0))
                    .opacity(0.67)
                
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

                    // Adds to coredata watch list, loads a new recommendation
                    Button  {
                        // Add to coredata, plot is derived from the ID in addcontent
                        dataModel.addContent(id: discoverModel.recommendedContent?.id ?? "",
                                                  name: discoverModel.recommendedContent?.title ?? "",
                                                  image: discoverModel.recommendationImageData ?? Data(),
                                                  year: discoverModel.recommendedContent?.year ?? 0)
                        
                        // Get a new recommendation
                        discoverModel.nextRecommendedContent()
                        
                        // Alert that it has been saved
                        addedToWatchlistAlertIsPresented = true
                    } label: {
                        HStack {
                            CustomButton(text:"Add to watch list", color:.green)
                        }
                    }
                }
            } else {
                Text("Loading...")
            }
            
            // Empty navigationlink used to navigate back to SearchView
            NavigationLink(destination: SearchView().navigationBarHidden(true), isActive: $showSearchView) { EmptyView() }
        }
        .padding()
        .task {
            // If nothing has been set yet for the Recommendation view, run API calls and display results
            if discoverModel.imdbSearchContent?.id == nil || discoverModel.searchCast.isEmpty {
                await discoverModel.getFullTitleInfo(id: (discoverModel.imdbSearchContent?.id)!)
                await discoverModel.getKnownForContent()
                discoverModel.nextRecommendedContent()
                discoverModel.isLoading = false
            } else {
                // If data has already been loaded, populate view
                discoverModel.nextRecommendedContent()
            }
        }
        .alert("Added to Watch List", isPresented: $addedToWatchlistAlertIsPresented) {
            Button {} label: {
                Text("Ok")
            }
        }
        .alert("End of available recommendations", isPresented: $discoverModel.noRecommendationsRemaining) {
            Button {
                // Navigates back to search
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
