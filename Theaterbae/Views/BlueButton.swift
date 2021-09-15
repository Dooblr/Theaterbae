//
//  Button.swift
//  Theaterbae
//
//  Created by admin on 9/15/21.
//

import SwiftUI

struct BlueButton: View {
    
    var text:String
    
    var body: some View {
        ZStack {
            Rectangle()
                .background(Color.blue)
                .frame(height:48)
                .cornerRadius(10)
            Text(text)
                .foregroundColor(Color.white)
        }.padding()
    }
}

struct BlueButton_Previews: PreviewProvider {
    static var previews: some View {
        BlueButton(text: "Test Text")
    }
}
