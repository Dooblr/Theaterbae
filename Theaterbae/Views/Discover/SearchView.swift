//
//  ContentView.swift
//  FlickFind
//
//  Created by admin on 9/12/21.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var model: DiscoverModel
    
    // Search field
    @State var inputString = ""
    
    @State var alertEmptyTextFieldIsPresented = false
    
    var body: some View {
        
        NavigationView {
         
            VStack {
                
                Text("Search a movie or show to get recommendations")
                
                TextField("The Office", text: $inputString)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .cornerRadius(20)
                
                NavigationLink(destination: ConfirmSearchResultView(title:inputString)) {
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
                inputString = ""
                // Reset the search index
                model.searchIndex = 0
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
