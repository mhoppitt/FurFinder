//
//  AddBreedSheetView.swift
//  FurFinder
//
//  Created by Matt Hoppitt on 6/1/2025.
//

import SwiftUI
import PhotosUI

struct AddBreedSheetView: View {
    var breed: FurFinderBreed
    @State var isEdit: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var photoImage: UIImage?
    @State var name : String = ""
    @State var dateTaken : Date = Date()
    @State var age : String = ""
    @State var funFact : String = ""
    @State var sex : String = "Male"
    @State var location : String = ""
    @State var presignedUrl: String = ""
    @State var showDatePicker = false

    let breedsService = BreedsService()
    
    var body: some View {
        VStack {
            HStack() {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                }.frame(maxWidth: .infinity, alignment: .leading)
                Text("\(isEdit ? "Edit" : "Add") Friend")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                Button(action: {
                    Task {
                        do {
                            let details: DogDetails = DogDetails(id: breedsService.generateID(), name: name, dateTaken: dateTaken, age: age, funFact: funFact, sex: sex, location: location)
                            let breed: FurFinderBreed = FurFinderBreed(id: breed.id, breedName: breed.breedName, isCaptured: true, details: details)
                            try await breedsService.addBreed(breed: breed)
                            dismiss()
                        } catch let error {
                            print(error)
                        }
                    }
                }) {
                    Text("Save")
                        .bold()
                        .disabled(name.isEmpty || age.isEmpty || funFact.isEmpty || sex.isEmpty || location.isEmpty)
                }.frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(.horizontal, 20)
            Form {
                HStack {
                    Text("Breed").bold()
                    Spacer()
                    Text(breed.breedName)
                }
                Section {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                    HStack {
                        Picker(selection: $sex, label: Text("Sex")) {
                            ForEach(["Male", "Female"], id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    HStack {
                        PhotosPicker("Select image", selection: $photoItem, matching: .images)
                            .onChange(of: photoItem) {
                                Task {
                                    if let loaded = try? await photoItem?.loadTransferable(type: Image.self) {
                                        let size = CGSize(width: 200, height: 200)
                                        photoImage = loaded.getUIImage(newSize: size)
                                        await breedsService.uploadToS3(withImage: photoImage ?? UIImage(), key: breed.id)
                                        if (isEdit) {
                                            isEdit.toggle()
                                        }
                                    } else {
                                        print("Failed")
                                    }
                                }
                            }
                        Spacer()
                        if (isEdit) {
                            AsyncImage(url: URL(string: presignedUrl)) { result in
                                result.image?
                                    .resizable()
                                    .scaledToFill()
                            }.frame(width: 50, height: 50)
                        } else {
                            if ((photoImage) != nil) {
                                Image(uiImage: photoImage!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipped()
                            }
                        }
                    }
                }
                Section {
                    TextField("Location",text: $location)
                    TextField("Fun Fact", text: $funFact, axis: .vertical)
                    HStack {
                        Text("Date Taken")
                        Spacer()
                        Button(action: {
                            withAnimation {
                                showDatePicker.toggle()
                            }
                        }) {
                            Text(dateTaken.formatted(date: .abbreviated, time: .omitted))
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(showDatePicker ? .indigo : colorScheme == .dark ? .white : .black)
                    }
                    if (showDatePicker) {
                        DatePicker("Date Taken",
                            selection: $dateTaken,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                    }
                }
                if (isEdit) {
                    Button(action: {
                        Task {
                            do {
                                try await breedsService.deleteBreed(breed: breed)
                                dismiss()
                            } catch let error {
                                print(error)
                            }
                        }
                    }) {
                        Text("Delete Friend")
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .font(.title3)
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .clipShape(.rect(cornerRadius: 20))
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
        }
        .padding(.top, 20)
        .background(colorScheme == .dark ? SwiftUI.Color.init(red: 0.11, green: 0.11, blue: 0.11) : SwiftUI.Color.init(red: 0.95, green: 0.95, blue: 0.97))
        .preferredColorScheme(colorScheme)
        .task {
            do {
                presignedUrl = try await breedsService.getPresignedUrl(breedName: breed.id)
            } catch {
                print("Message update failed.")
            }
        }
    }
}

extension Image {
    @MainActor
    func getUIImage(newSize: CGSize) -> UIImage? {
        let image = resizable()
            .scaledToFill()
            .frame(width: newSize.width, height: newSize.height)
            .clipped()
        return ImageRenderer(content: image).uiImage
    }
}

#Preview {
    AddBreedSheetView(breed: FurFinderBreed(id: "AlaskanHusky", breedName: "Alaskan Husky", isCaptured: false, details: DogDetails(id: "", name: "", dateTaken: Date(), age: "", funFact: "", sex: "", location: "")), isEdit: true)
}
