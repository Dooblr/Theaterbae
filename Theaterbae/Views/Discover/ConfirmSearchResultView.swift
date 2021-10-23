//
//  ResultView.swift
//  Theaterbae
//
//  Created by admin on 9/15/21.
//

import SwiftUI

struct ConfirmSearchResultView: View {
    
    @EnvironmentObject var discoverModel: DiscoverModel
    
    @State var showSearchView = false
    
    var title: String
    
    var body: some View {
        
        VStack{
            
            if discoverModel.isLoading == false {
                let uiImage = UIImage(data: discoverModel.confirmTitleImageData ?? Data())
                Image(uiImage: uiImage ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
    //                .redacted(reason: .placeholder)
                Text(discoverModel.searchContent?.title ?? "")
                    .font(.title)
    //                .redacted(reason: SwiftUI.RedactionReasons.)
                
                Spacer()
                
                Text("Is this the content you're looking for?").padding()
                
                // Yes/No buttons
                HStack{
                    
                    // Move to the recomendation view
                    NavigationLink(destination: RecommendationView()) {
                        CustomButton(text: "Yes", color: .green)
                    }
                    
                    Button {
                        // Increment the search index to look for the next title in the list of resulting titles
                        discoverModel.searchIndex += 1
                        discoverModel.getIMDBTitle(title: title)
                    } label: {
                        CustomButton(text: "No", color: .red)
                    }
                }
                .padding()
            } else {
                Text("Loading...")
            }
            
            // TODO: Navigate transition left instead of right
            NavigationLink(destination: SearchView().navigationBarHidden(true), isActive: self.$showSearchView) { EmptyView() }
            
        }.onAppear {
            discoverModel.getIMDBTitle(title: title)
        }.alert("End of available content", isPresented: $discoverModel.autoSearchAlertIsPresented) {
//            Alert(title: Text("Alert"), message: Text("End of results"), dismissButton: .default(Text("Ok")))
            Button("Ok") {
                self.showSearchView = true
            }
        }.alert("No internet connection", isPresented: $discoverModel.alertNoInternet) {
            Button("Ok") {
                self.showSearchView = true
            }
        }
    }
}

//struct ResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultView()
//    }
//}
