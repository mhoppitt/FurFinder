//
//  BreedView.swift
//  FurFinder
//
//  Created by Matt Hoppitt on 6/1/2025.
//

import SwiftUI

struct BreedView: View {
    var breed: FurFinderBreed

    var body: some View {
        VStack {
            VStack {
                Image(String(breed.id)).resizable().scaledToFit()
            }
            .frame(height: 80)
            .saturation(breed.isCaptured ? 1 : 0)
            .opacity(breed.isCaptured ? 1 : 0.5)
            Text(breed.breedName)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(breed.isCaptured ? Color.black : Color.gray)
        }
    }
}

#Preview {
    BreedView(breed: FurFinderBreed(id: "id", breedName: "breedName", isCaptured: true, details: DogDetails(id: "dogId", name: "dogName", dateTaken: Date(), age: "age", funFact: "funFact", sex: "sex", location: "location")))
}
