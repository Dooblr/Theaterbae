//
//  WatchListModel.swift
//  Theaterbae
//
//  Created by admin on 10/14/21.
//

import Foundation
import CoreData

class WatchListModel: ObservableObject {
    
    // Array of saved titles
    @Published var watchList = ["one", "two", "three"]
    
    
    let container: NSPersistentContainer
    @Published var savedEntities: [ContentEntity] = []
    
    init(){
        container = NSPersistentContainer(name: "ContentData")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("error loading CoreData. \(error)")
            } else {
                print("Successfully loaded CoreData")
            }
        }
        fetchContent()
    }
    
    func fetchContent() {
        let request = NSFetchRequest<ContentEntity>(entityName: "ContentEntity")
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching \(error)")
        }
        
    }
    
    func addContent(name: String) {
        
        let newContent = ContentEntity(context: container.viewContext)
        newContent.name = name
        saveData()
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchContent()
        } catch let error {
            print("Error saving. \(error)")
        }
        
    }
}
