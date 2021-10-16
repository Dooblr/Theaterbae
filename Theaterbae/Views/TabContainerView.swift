//
//  TabContainerView.swift
//  Theaterbae
//
//  Created by admin on 10/14/21.
//

import SwiftUI

struct TabContainerView: View {
    var body: some View {
        TabView{
            SearchView()
                .tabItem {
                    Image(systemName: "binoculars")
                    Text("Discover")
                }
            WatchListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Watch List")
                }
            
        }
    }
}

struct TabContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TabContainerView()
    }
}
