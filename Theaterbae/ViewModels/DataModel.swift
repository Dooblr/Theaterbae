//
//  WatchListModel.swift
//  Theaterbae
//
//  Created by admin on 10/14/21.
//

import Foundation
import CoreData

class DataModel: ObservableObject {
    
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
    
    func addContent(id: String, name: String, image: Data) {
        
        let newContent = ContentEntity(context: container.viewContext)
        newContent.id = id
        newContent.name = name
        newContent.image = image
        saveData()
    }
    
    func deleteContent(indexSet:IndexSet) {
        guard let index = indexSet.first else { return }
        let entity = savedEntities[index]
        container.viewContext.delete(entity)
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