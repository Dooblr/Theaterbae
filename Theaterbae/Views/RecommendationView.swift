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
            let uiImage = UIImage(data: model.imageData ?? Data())
            Image(uiImage: uiImage ?? UIImage())
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
            Text(model.newContent?.title ?? "")
        }.onAppear {
            model.getNewRecommendation()
        }
    }
}

struct RecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationView()
    }
}
