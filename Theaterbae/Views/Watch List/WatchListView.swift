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
                    ForEach(dataModel.savedEntities, id:\.self) { item in
                        NavigationLink (destination: WatchListDetailView()) {
                            HStack{
                                
                                let uiImage = UIImage(data: item.image ?? Data())
                                Image(uiImage: uiImage ?? UIImage())
                                    .resizable()
                                    .scaledToFill()
                                    .cornerRadius(10)
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(height: UIScreen.main.bounds.height/12)
                                    .padding(.vertical)
                                    
                                Text(item.name ?? "")
                                
                                Spacer()
                                
                                Image(systemName: "info.circle").foregroundColor(.gray)
                            }
                        }
                    }.onDelete(perform: dataModel.deleteContent)
                }
    //            Button {
    //
    //            } label: {
    //                CustomButton(text: "Delete all", color: .red)
    //            }

            }
            .onAppear {
                
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
