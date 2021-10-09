//
//  ContentView.swift
//  FlickFind
//
//  Created by admin on 9/12/21.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var model: ContentModel
    
    // Search field
    @State var inputString = ""
    
    @State var alertTextFieldIsEmptyIsPresented = false
    
    
    var body: some View {
        
        NavigationView {
         
            VStack {
                
                Text("Search a movie or show to get recommendations")
                
                TextField("The Office", text: $inputString)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .cornerRadius(20)
                
                NavigationLink(destination: SearchResultView(title:inputString)) {
                    CustomButton(text:"Search", color: .blue)
                }
                .disabled(inputString == "")
                .onTapGesture {
                    if (inputString == "") {
                        alertTextFieldIsEmptyIsPresented = true
                    }
                }
                Spacer()
                    
            }
            .padding()
            .onAppear {
                inputString = ""
            }
            .alert("Enter a movie or show title to find recommendations", isPresented: $alertTextFieldIsEmptyIsPresented, actions: {
                Button {
                    alertTextFieldIsEmptyIsPresented = false
                } label: {
                    Text("Ok")
                }

            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
