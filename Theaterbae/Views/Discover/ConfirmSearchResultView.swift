//
//  ResultView.swift
//  Theaterbae
//
//  Created by admin on 9/15/21.
//

import SwiftUI

struct ConfirmSearchResultView: View {
    
    // Access to view driving model
    @EnvironmentObject var discoverModel: DiscoverModel
    
    // Programattic transition change
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
                
                VStack{
                    Text("Recommend something new based on this content?")
                    Text("Tap no to try another title").foregroundColor((Color.primary).opacity(0.33))
                }.padding()
                
                // Yes/No buttons
                HStack{
                    
                    // Move to the recomendation view
                    NavigationLink(destination: RecommendationView()) {
                        CustomButton(text: "Yes", color: .green)
                    }
                    
                    Button {
                        // Increment the search index to look for the next title in the list of resulting titles
                        // TODO: fix getIMDBTitle() so it calls once and this button increments and reloads
                        discoverModel.searchIndex += 1
//                        discoverModel.getIMDBTitle(title: title)
                        discoverModel.showNewSearchResult()
                    } label: {
                        CustomButton(text: "No", color: .red)
                    }
                }
                .padding()
            } else {
                Text("Loading...")
            }
            
            // TODO: Navigate transition left instead of right
            NavigationLink(destination: SearchView().navigationBarHidden(true), isActive: $showSearchView) { EmptyView() }
            
        }.onAppear {
            discoverModel.getIMDBTitle(title: title) {
                discoverModel.showNewSearchResult()
            }
        }.alert("End of available content", isPresented: $discoverModel.autoSearchAlertIsPresented) {
//            Alert(title: Text("Alert"), message: Text("End of results"), dismissButton: .default(Text("Ok")))
            Button("Ok") {
                showSearchView = true
            }
        }.alert("No internet connection", isPresented: $discoverModel.alertNoInternet) {
            Button("Ok") {
                showSearchView = true
            }
        }
    }
}

//struct ResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultView()
//    }
//}
