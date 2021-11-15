//
//  ResultView.swift
//  Theaterbae
//
//  Created by admin on 9/15/21.
//

import SwiftUI

struct ConfirmSearchView: View {
    
    // Access to view driving model
    @EnvironmentObject var discoverModel: DiscoverModel
    
    // Programattic transition change
    @State var showSearchView = false
    
//    @State var 
    
    var title: String
    
    var body: some View {
        
        VStack{
            
            if discoverModel.isLoading == false {
                let uiImage = UIImage(data: discoverModel.confirmTitleImageData ?? Data())
                Image(uiImage: uiImage ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .padding(.vertical)
    //                .redacted(reason: .placeholder)
                
                // Title/name
                Text(discoverModel.imdbSearchContent?.title ?? "")
                    .font(.title)
                
                // Year
//                Text(String(discoverModel.searchContent?.year ?? 0))
//                    .opacity(0.67)
                
                Spacer()
                
                VStack{
                    Text("Recommend something new based on this content?").padding(.bottom)
                    Text("Tap no to try another title").opacity(0.67)
                }.padding()
                
                // Yes/No buttons
                HStack{
                    
                    // Move to the recomendation view
                    NavigationLink(destination: RecommendationView()) {
                        CustomButton(text: "Yes", color: .green)
                    }
                    
                    Button {
                        // Increment the search index to get the next title
                        discoverModel.searchIndex += 1
                        discoverModel.showNewImdbSearchResult()
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
            if discoverModel.imdbSearchContent == nil {
                Task{
                    await discoverModel.searchAll(title: title)
                    discoverModel.showNewImdbSearchResult()
                }
            } else {
                discoverModel.showNewImdbSearchResult()
            }
        }
        .alert("End of available content", isPresented: $discoverModel.autoSearchAlertIsPresented) {
//            Alert(title: Text("Alert"), message: Text("End of results"), dismissButton: .default(Text("Ok")))
            Button("Ok") {
                showSearchView = true
            }
        }.alert("No internet connection", isPresented: $discoverModel.alertNoInternet) {
            Button("Ok") {
                showSearchView = true
            }
        }
        // Hide navigation bar space
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct ResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultView()
//    }
//}