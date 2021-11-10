//
//  Constants.swift
//  Theaterbae
//
//  Created by admin on 9/12/21.
//

import Foundation
import Firebase

struct Constants {
    
    static var rapidApiHostHeader = "x-rapidapi-host"
    static var rapidApiKeyHeader = "x-rapidapi-key"
    
    static var rapidApiHostValue:String?
    static var rapidApiKeyValue:String?
    
    // Combined value dictionary
    static var rapidApiHeaders:[String:String]?
    
    // Accesses Firebase to retrieve API keys
    init() {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        let docRef = db.collection("rapidapi").document("0")
        docRef.getDocument { (document, error) in
            Constants.rapidApiHostValue = document!.data()![Constants.rapidApiHostHeader] as? String
            Constants.rapidApiKeyValue = document!.data()![Constants.rapidApiKeyHeader] as? String
            Constants.rapidApiHeaders = [Constants.rapidApiHostHeader:Constants.rapidApiHostValue!,
                                         Constants.rapidApiKeyHeader:Constants.rapidApiKeyValue!]
        }
    }
}
