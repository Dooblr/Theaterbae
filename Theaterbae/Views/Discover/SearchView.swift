//
//  ContentView.swift
//  Theaterbae
//
//  Created by admin on 9/12/21.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var discoverModel: DiscoverModel
    
    // Search field
    @State var inputString = ""
    
    @State var alertEmptyTextFieldIsPresented = false
    
    var body: some View {
        
        NavigationView() {
         
            VStack {
                
                Text("Search a movie or show to get recommendations")
                
                TextField("Type in a movie or TV show", text: $inputString)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .cornerRadius(20)
                
                NavigationLink(destination: ConfirmSearchView(title:inputString)) {
                    CustomButton(text:"Search", color: .blue)
                }
                .disabled(inputString == "")
                .onTapGesture {
                    if (inputString == "") {
                        alertEmptyTextFieldIsPresented = true
                    }
                }
                Spacer()   
            }
            .padding()
            .navigationTitle("Discover")
            .onAppear {
                
                // Clear the input string
                inputString = ""
                
                // Clear search index
                discoverModel.searchIndex = 0
                
                // Clear search content
                discoverModel.imdbSearchContent = nil
                
                // Clear cast list
                discoverModel.searchCast = []
                
                // Clear known for content
                discoverModel.knownForContent = []
            }
            .alert("Enter a movie or show title to find recommendations", isPresented: $alertEmptyTextFieldIsPresented) {
                Button {
                    alertEmptyTextFieldIsPresented = false
                } label: {
                    Text("Ok")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
