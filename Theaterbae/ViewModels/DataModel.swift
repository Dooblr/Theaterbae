//
//  WatchListModel.swift
//  Theaterbae
//
//  Created by admin on 10/14/21.
//

import Foundation
import CoreData
import SwiftUI

class DataModel: ObservableObject {
    
    let container = PersistenceController.shared.container
    @Published var savedEntities: [ContentEntity] = []
    
    init(){
//        container = NSPersistentContainer(name: "ContentData")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("error loading CoreData. \(error)")
            } else {
                print("Successfully loaded CoreData")
            }
        }
        fetchContent()
    }
    
    func fetchContent()  {
        let request = NSFetchRequest<ContentEntity>(entityName: "ContentEntity")
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching \(error)")
        }
    }
    
    func addContent(id:String, name:String, image:Data, year:Int) {
        
        // Create a new data entity
        let newContent = ContentEntity(context: container.viewContext)
        
        // remove /title/.../
        let strippedID = String(id.dropFirst(7).dropLast(1))
        
        // Set data values
        newContent.id = strippedID
        newContent.name = name
        newContent.image = image
        newContent.year = Int64(year)
        // Asynchronously run the plot API call with ID
        Task{
            newContent.plot = await DiscoverModel.getContentPlot(imdbContentID: strippedID)
        }

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
