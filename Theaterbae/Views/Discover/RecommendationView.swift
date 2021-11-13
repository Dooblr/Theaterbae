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
                
                HStack {
                   
                    // Revert back button
                    Button {
                        discoverModel.revertRecommendedContent()
                    } label: {
                        HStack {
                            CustomButton(text:"Back", color:.yellow)
                        }
                    }

                    
                    // Adds to coredata watch list, loads a new recommendation
                    Button  {
                        // Add to coredata, plot is derived from the ID in addcontent
                        dataModel.addContent(id: discoverModel.recommendedContent?.id ?? "",
                                                  name: discoverModel.recommendedContent?.title ?? "",
                                                  image: discoverModel.recommendationImageData ?? Data(),
                                                  year: discoverModel.recommendedContent?.year ?? 0)
                        
                        // Get a new recommendation
                        discoverModel.setRecommendedContent()
                        
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
            
            NavigationLink(destination: SearchView().navigationBarHidden(true), isActive: $showSearchView) { EmptyView() }
        }
        .padding()
        .task {
            // If nothing has been set yet for the Recommendation view, run API calls and display results
            if discoverModel.imdbSearchContent?.id == nil || discoverModel.searchCast == [] {
                await discoverModel.getFullTitleInfo(id: (discoverModel.imdbSearchContent?.id)!)
                discoverModel.getKnownForContentFromCast {
                    // Get a new recommendation
                    discoverModel.setRecommendedContent()
                }
            } else {
                // Use pre-set data to populate views
                discoverModel.setRecommendedContent()
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
