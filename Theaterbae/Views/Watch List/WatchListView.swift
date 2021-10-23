//
//  WatchListView.swift
//  Theaterbae
//
//  Created by admin on 10/14/21.
//

import SwiftUI

struct WatchListView: View {
    
    @EnvironmentObject var model: WatchListModel
    
    var body: some View {
        
        VStack{
            List{
                ForEach(model.savedEntities, id:\.self) { item in
                    Text(item.name!)
                }.onDelete(perform: model.deleteContent)
            }
//            Button {
//
//            } label: {
//                CustomButton(text: "Delete all", color: .red)
//            }

        }
    }
}

struct KeepListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListView()
    }
}
