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
        VStack {
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
            }.frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            AsyncImage(url: URL(string: presignedUrl)) { result in
                result.image?
                    .resizable()
                    .scaledToFill()
            }.frame(width: 300, height: 300)
            HStack {
                VStack {
                    Text(breed.details.name)
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    Text(breed.breedName)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                HStack {
                    Capsule()
                        .fill(Color.accentColor)
                        .opacity(0.3)
                        .overlay(
                            Text(breed.details.dateTaken.formatted(date: .abbreviated, time: .omitted))
                        )
                        .frame(width: 150)
                }.frame(height: 50)
            }.padding()
            Spacer()
                HStack {
                    CapsuleView(imageName: "calendar.circle.fill", displayText: breed.details.age)
                    CapsuleView(imageName: "pawprint.circle.fill", displayText: breed.details.sex)
                    CapsuleView(imageName: "location.circle.fill", displayText: breed.details.location)
                }
            CapsuleView(imageName: "dog.circle.fill", displayText: breed.details.funFact)
            Spacer()
            Button(action: {
                withAnimation {
                    self.isPresentingEditBreed = breed
                    self.isPresentingCapturedBreed = nil
                }
            }) {
                Text("Edit Friend")
                    .frame(maxWidth: .infinity, maxHeight: 30)
            }
            .buttonStyle(.bordered)
            .listRowInsets(EdgeInsets())
            .background(Color(UIColor.systemGroupedBackground))
            Spacer()
        }
        .padding()
        .padding(.top, 13)
        .task {
            do {
                presignedUrl = try await breedsService.getPresignedUrl(breedName: breed.id)
            } catch {
                print("Message update failed.")
            }
        }
    }
}

//#Preview {
//    CapturedSheetView(breed: FurFinderBreed(id: "AlaskanHusky", breedName: "Alaskan Husky", isCaptured: true, details: DogDetails(id: "dogId", name: "Buddy", dateTaken: Date(), age: "1 year", funFact: "funFac cwdjkhfw cdwuihcwbcw cuibc scq qsxubxq qwdkubqxsdhlds cduhilcdjkcdw cdwuilcdw t", sex: "Male", location: "Sydney CBD")), presignedUrl: "")
//}
