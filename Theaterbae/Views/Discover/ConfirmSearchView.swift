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

                Spacer()
                AsyncImage(url: URL(string: discoverModel.imdbSearchContent?.image ?? ""))
                    { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                }
                
                // Title/name
                Text(discoverModel.imdbSearchContent?.title ?? "")
                    .font(.title)
                
                Spacer()
                
                VStack{
                    Text("Recommend something new based on this content?").padding(.bottom)
                    Text("Tap no to try another title").opacity(0.67)
                }.padding()
                
                // Yes/No buttons
                HStack{
                    
                    // Button to proceed to the recomendation view
                    NavigationLink(destination: RecommendationView()) {
                        CustomButton(text: "Yes", color: .green)
                    }
                    
                    // Button to get the next title
                    Button {
                        discoverModel.searchIndex += 1
                        discoverModel.showNewImdbSearchResult()
                    } label: {
                        CustomButton(text: "No", color: .red)
                    }
                }.padding()
            } else {
                Text("Loading...")
            }
            
            // TODO: Navigate transition left instead of right
            NavigationLink(destination: SearchView().navigationBarHidden(true), isActive: $showSearchView) { EmptyView() }
        }.task {
            if discoverModel.imdbSearchContent == nil {
                await discoverModel.searchAll(title: title)
            }
            discoverModel.showNewImdbSearchResult()
        }
        .alert("End of available content", isPresented: $discoverModel.alertNoSearchResultsRemaining) {
            Button("Ok") {
                showSearchView = true
            }
        }
        .alert("No internet connection", isPresented: $discoverModel.alertNoInternet) {
            Button("Ok") {
                showSearchView = true
            }
        }
        // Hide navigation bar space
        .navigationBarTitleDisplayMode(.inline)
    }
}
