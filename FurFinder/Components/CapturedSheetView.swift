//
//  CapturedSheetView.swift
//  FurFinder
//
//  Created by Matt Hoppitt on 6/1/2025.
//

import SwiftUI

struct CapturedSheetView: View {
    var breed: FurFinderBreed
    var breedsService = BreedsService()
    
    @StateObject var model = BreedsModel()
    @State var presignedUrl: String
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var isPresentingEditBreed: FurFinderBreed?
    @Binding var isPresentingCapturedBreed: FurFinderBreed?

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
            }
            .padding(.top, 5)
            .padding(.bottom)
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack {
                AsyncImage(url: URL(string: presignedUrl)) { result in
                    result.image?
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 300)
                        .cornerRadius(16)
                }
                Text(breed.details.name)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                Text(breed.breedName)
                    .font(.title2)
                    .multilineTextAlignment(.center)
            }.frame(maxWidth: .infinity, alignment: .center)
            Spacer()
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    Text("Snapped on \(breed.details.dateTaken.formatted(date: .abbreviated, time: .omitted))")
                }
                HStack(spacing: 10) {
                    Image(systemName: "clock")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    Text(breed.details.age)
                }
                HStack(spacing: 10) {
                    Text(breed.details.sex == "Male" ? "\u{2642}" : "\u{2640}")
                        .font(.title2)
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    Text(breed.details.sex)
                }
                HStack(spacing: 10) {
                    Image(systemName: "location")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    Text(breed.details.location)
                }
            }
            Spacer()
            Button(action: {
                withAnimation {
                    self.isPresentingEditBreed = breed
                    self.isPresentingCapturedBreed = nil
                }
            }) {
                Text("Edit Friend")
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .font(.title3)
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .clipShape(.rect(cornerRadius: 20))
            Spacer()
        }
        .padding(20)
        .task {
            do {
                presignedUrl = try await breedsService.getPresignedUrl(breedName: breed.id)
            } catch {
                print("Message update failed.")
            }
        }
    }
}

#Preview {
    CapturedSheetView(breed: FurFinderBreed(id: "AlaskanHusky", breedName: "Alaskan Husky", isCaptured: true, details: DogDetails(id: "dogId", name: "Buddy", dateTaken: Date(), age: "1 year", funFact: "", sex: "Male", location: "Sydney CBD")), presignedUrl: "", isPresentingEditBreed: .constant(.none), isPresentingCapturedBreed: .constant(.none))
}
