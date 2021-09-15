//
//  TheaterbaeApp.swift
//  Theaterbae
//
//  Created by admin on 9/15/21.
//

import SwiftUI

@main
struct TheaterbaeApp: App {
    var body: some Scene {
        WindowGroup {
            SearchView().environmentObject(ContentModel())
        }
    }
}
