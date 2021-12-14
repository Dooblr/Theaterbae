//
//  WatchListView.swift
//  Theaterbae
//
//  Created by admin on 10/14/21.
//

import SwiftUI

struct WatchListView: View {
    
    @EnvironmentObject var dataModel: DataModel
    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    ForEach(dataModel.savedEntities, id:\.self) { content in
                        NavigationLink (destination: WatchListDetailView(content: content)) {
                            HStack {
                                
                                let uiImage = UIImage(data: content.image ?? Data())
                                Image(uiImage: uiImage ?? UIImage())
                                    .resizable()
                                    .scaledToFill()
                                    .cornerRadius(10)
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(height: UIScreen.main.bounds.height/12)
                                    .padding(.vertical)
                                    
                                Text(content.name ?? "")
                                    .font(.title2)
                                    .padding(.leading, UIScreen.main.bounds.width/15)
                                
                                Spacer()
                                
                                Image(systemName: "info.circle").foregroundColor(.gray)
                            }
                        }
                    }.onDelete(perform: dataModel.deleteContent)
                }
            }
            .navigationBarTitle("Watch List")
        }
    }
}

struct KeepListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListView()
    }
}
