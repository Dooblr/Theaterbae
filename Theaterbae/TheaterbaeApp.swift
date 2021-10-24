//
//  TheaterbaeApp.swift
//  Theaterbae
//
//  Created by admin on 9/15/21.
//

import SwiftUI

@main
struct TheaterbaeApp: App {
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            TabContainerView()
                .environmentObject(DiscoverModel())
                .environmentObject(DataModel())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
