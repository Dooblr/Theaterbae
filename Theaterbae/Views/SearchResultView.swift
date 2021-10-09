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
                .font(.title)
            
            Spacer()
            
            Text("Is this the content you're looking for?").padding()
            
            // Yes/No buttons
            HStack{
                
                NavigationLink(destination: RecommendationView()) {
                    CustomButton(text: "Yes", color: .green)
                }
                
                Button {
                    model.searchIndex += 1
                    model.getIMDBTitle(title: title)
                } label: {
                    CustomButton(text: "No", color: .red)
                }
            }
            
            NavigationLink(isActive: $model.searchViewNavIsActive, destination: { SearchView() }, label: {
                EmptyView()
            })
        }.onAppear {
            model.getIMDBTitle(title: title)
        }.alert("End of available content", isPresented: $model.alertIsPresented) {
//            Alert(title: Text("Alert"), message: Text("End of results"), dismissButton: .default(Text("Ok")))
            Button("OK", role:.cancel) {
                model.searchViewNavIsActive = true
            }
            
        }
    }
}

//struct ResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultView()
//    }
//}
