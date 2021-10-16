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
    
    var body: some View {
        VStack{
            
            if discoverModel.isLoading == false {
                
                let uiImage = UIImage(data: discoverModel.imageData ?? Data())
                Image(uiImage: uiImage ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                
                Text(discoverModel.recommendedContent?.title ?? "")
                    .font(.title)
                
                // Provides a new recommendation
                Button {
                    discoverModel.getCastFromId(IMDBId: (discoverModel.searchContent?.id)!)
                } label: {
                    CustomButton(text:"New Recommendation", color:.blue)
                }
                
                Spacer()
                
                // Adds to watch list, loads a new recommendation, TODO: provides an alert
                Button  {
                    watchListModel.addContent(name: discoverModel.recommendedContent?.title ?? "")
                    discoverModel.getCastFromId(IMDBId: (discoverModel.searchContent?.id)!)
                } label: {
                    CustomButton(text:"Add to watch list", color:.green)
                }

            } else {
                Text("Loading...")
            }
        }
        .padding()
        .onAppear {
            discoverModel.getCastFromId(IMDBId: (discoverModel.searchContent?.id)!)
        }
    }
}

struct RecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationView()
    }
}
