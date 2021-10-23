//
//  RecommendationView.swift
//  Theaterbae
//
//  Created by admin on 9/15/21.
//

import SwiftUI

struct RecommendationView: View {
    
    @EnvironmentObject var discoverModel:DiscoverModel
    @EnvironmentObject var watchListModel:WatchListModel
    
    @State var addedToWatchlistAlertIsPresented = false
    
    
    
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
                    watchListModel.addContent(name: discoverModel.recommendedContent?.title ?? "")
                    
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
        }
        .padding()
        .onAppear {
            discoverModel.getCastFromId(IMDBId: (discoverModel.searchContent?.id)!) {
                // Get a new recommendation
                discoverModel.getKnownForContentFromCast {
                    discoverModel.setRecommendedContent()
                }
            }
            
        }
        .alert("Added to Watch List", isPresented: $addedToWatchlistAlertIsPresented) {
            Button {} label: {
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
