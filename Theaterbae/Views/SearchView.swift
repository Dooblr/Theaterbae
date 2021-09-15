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
    
    var body: some View {
        
        NavigationView {
         
            VStack {
                
                Text("Enter a movie to find recommendations")
                
                TextField("Enter a movie title", text: $inputString)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                NavigationLink(destination: SearchResultView(title:inputString)) {
                    BlueButton(text:"Search")
                }
            }.padding()
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
