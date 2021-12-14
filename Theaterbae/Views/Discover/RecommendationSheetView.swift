//
//  RecommendationSheetView.swift
//  Theaterbae
//
//  Created by admin on 11/25/21.
//

import SwiftUI

struct RecommendationSheetView: View {
    
    var sheetTitle:Title
    
    var body: some View {
        
        // MARK: - Genre
        
        Text("Genre").font(.title2)
        Text((sheetTitle.genres) ?? "").onAppear {
            print(sheetTitle.trailer?.linkEmbed ?? "")
        }
        
        // MARK: - Year

        Text((sheetTitle.year) ?? "").opacity(0.67)
        
        Spacer()
        
        // MARK: - Plot
        Text("Plot").font(.title2)
        Text(sheetTitle.plot ?? "")
        
        Spacer()
        
        // MARK: - Rating
        
        Text("Rating").font(.title2)
        
        // Stars
        let ratingInt = Int((sheetTitle.imDbRating)!)!
        HStack {
//            ForEach(dataModel.savedEntities, id:\.self) { content in
            ForEach((0...ratingInt), id: \.self) {_ in
                Image(systemName: "star.fill")
            }
        }
        
        // Text
        Text(sheetTitle.imDbRating ?? "")
    }
}
