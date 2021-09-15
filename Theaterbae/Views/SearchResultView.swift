//
//  ResultView.swift
//  Theaterbae
//
//  Created by admin on 9/15/21.
//

import SwiftUI

struct SearchResultView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var title: String
    
    var body: some View {
        
        VStack{
            let uiImage = UIImage(data: model.imageData ?? Data())
            Image(uiImage: uiImage ?? UIImage())
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
            Text(model.searchContent?.title ?? "")
            
            NavigationLink(destination: RecommendationView()) {
                BlueButton(text:"Recommend")
            }

        }.onAppear {
            model.getIMDBTitle(title: title)
        }
    }
}

//struct ResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultView()
//    }
//}
