//
//  CapsuleView.swift
//  FurFinder
//
//  Created by Matt Hoppitt on 17/1/2025.
//

import SwiftUI

struct CapsuleView: View {
    var imageName: String
    var displayText: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 25, height: 25)
            Text(displayText)
        }
        .multilineTextAlignment(.center)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 25).fill(Color.accentColor).opacity(0.3))
    }
}

#Preview {
    CapsuleView(imageName: "dog.circle.fill", displayText: "text")
}
