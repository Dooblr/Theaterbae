//
//  RecommendationView.swift
//  Theaterbae
//
//  Created by admin on 9/15/21.
//

import SwiftUI

struct RecommendationView: View {
    
    @EnvironmentObject var discoverModel:DiscoverModel
    @EnvironmentObject var watchListModel:DataModel
    
    // Alerts
    @State var addedToWatchlistAlertIsPresented = false
    
    // Toggle for navigating back to SearchView
    @State var showSearchView = false
    
    var body: some View {
        VStack{
            
            if discoverModel.isLoading == false {
                
                let uiImage = UIImage(data: discoverModel.recommendationImageData ?? Data())
                Image(uiImage: uiImage ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                
                Text(discoverModel.recommendedContent?.title ?? "")
                    .font(.title)
                
                Text(String(discoverModel.recommendedContent?.year ?? 0))
                    .opacity(0.67)
                
                
                // Provides a new recommendation
                Button {
                    // Get a new recommendation
                    discoverModel.setRecommendedContent()
                } label: {
                    CustomButton(text:"New Recommendation", color:.blue)
                }
                
                Spacer()
                
                // Adds to watch list, loads a new recommendation, TODO: provides an alert
                Button  {
                    // Add to coredata
                    watchListModel.addContent(id: discoverModel.recommendedContent?.id ?? "",
                                              name: discoverModel.recommendedContent?.title ?? "",
                                              image: discoverModel.recommendationImageData ?? Data())
                    
                    // Get a new recommendation
                    discoverModel.setRecommendedContent()
                    
                    // Alert that it has been saved
                    addedToWatchlistAlertIsPresented = true
                } label: {
                    CustomButton(text:"Add to watch list", color:.green)
                }

            } else {
                Text("Loading...")
            }
            
            NavigationLink(destination: SearchView().navigationBarHidden(true), isActive: $showSearchView) { EmptyView() }
        }
        .padding()
        .onAppear {
            // If nothing has been set yet for the Recommendation view, run API calls and display results
            if discoverModel.searchContent?.id == nil || discoverModel.searchCast == nil {
                discoverModel.getCastFromId(IMDBId: (discoverModel.searchContent?.id)!) {
                    discoverModel.getKnownForContentFromCast {
                        // Get a new recommendation
                        discoverModel.setRecommendedContent()
                    }
                }
            } else {
                // Use pre-set data to populate views
                discoverModel.setRecommendedContent()
            }
            
        }
        .onDisappear {
            // clear known for content on navigating away
            discoverModel.knownForContent = []
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
