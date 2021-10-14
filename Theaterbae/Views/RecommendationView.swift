//
//  RecommendationView.swift
//  Theaterbae
//
//  Created by admin on 9/15/21.
//

import SwiftUI

struct RecommendationView: View {
    
    @EnvironmentObject var model:ContentModel
    
    var body: some View {
        VStack{
            
            if model.isLoading == false {
                let uiImage = UIImage(data: model.imageData ?? Data())
                Image(uiImage: uiImage ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                Text(model.recommendedContent?.title ?? "")
                    .font(.title)
                Button {
                    model.getCastFromId(IMDBId: (model.searchContent?.id)!)
                    // TODO: Check if length of recommendedTitles has been hit
                    // TODO: if so, throw an alert and return to search screen
                    
                    
                } label: {
                    CustomButton(text:"New Recommendation", color:.blue)
                }
            } else {
                Text("Loading...")
            }
        }
        .padding()
        .onAppear {
            model.getCastFromId(IMDBId: (model.searchContent?.id)!)
        }
    }
}

struct RecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationView()
    }
}
