//
//  WatchListDetailView.swift
//  Theaterbae
//
//  Created by admin on 10/24/21.
//

import SwiftUI

struct WatchListDetailView: View {
    
    @EnvironmentObject var discoverModel:DiscoverModel
    
    var content:ContentEntity
    
    var body: some View {
        
        ScrollView {
            VStack{
                
                // Image
                let uiImage = UIImage(data: content.image ?? Data())
                Image(uiImage: uiImage ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .padding(.vertical)
                    .frame(width:UIScreen.main.bounds.width * 0.67)
                
                // Name
                Text(content.name ?? "")
                    .font(.title2)
                    .padding(.bottom)
                
                // Year
                Text("\(content.year)".filter { $0 != "," })
                    .opacity(0.67)
                    .padding(.bottom)
                
                // Summary
                if content.plot != nil {
                    Text(content.plot!)
                        .padding()
                } else {
                    Text("No plot or summary found")
                }
            }
            .navigationTitle("Details")
        }
    }
}

//struct WatchListDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        WatchListDetailView()
//    }
//}
