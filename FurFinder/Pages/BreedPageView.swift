//
//  BreedPageView.swift
//  FurFinder
//
//  Created by Matt Hoppitt on 6/1/2025.
//

import SwiftUI

@MainActor
class BreedsModel: ObservableObject {
    @Published var breedList: [FurFinderBreed]?
    @Published var filteredBreedList: [FurFinderBreed]?
    var breedsService = BreedsService()
    @State var filterActive: Bool = false

    init() {}

    func fetchBreeds() async {
        do {
            breedList = try await breedsService.getBreeds()
        } catch let error {
            print(error)
        }
    }
    
    func fetchFilteredBreeds() async {
        do {
            breedList = try await breedsService.getBreeds()
            filteredBreedList = breedList!.filter { $0.isCaptured == false }
        } catch let error {
            print(error)
        }
    }
}

struct BreedPageView: View {
    @StateObject var model = BreedsModel()
    @State public var refreshed: Bool = false
    @State private var isPresentingAddBreed: FurFinderBreed? = nil
    @State var isPresentingEditBreed: FurFinderBreed? = nil
    @State private var isPresentingCapturedBreed: FurFinderBreed? = nil
    @State private var showingSpinner: Bool = true
    @State private var showSearchBar: Bool = false
    @State private var searchText = ""
    @State private var filterActive: Bool = false
    
    let columns = [
        GridItem(.fixed(130)),
        GridItem(.fixed(130)),
        GridItem(.fixed(130))
    ]
    
    func refreshView() {
        return refreshed.toggle()
    }
    
    var body: some View {
        NavigationStack {
            if (showSearchBar) {
                withAnimation {
                    SearchBar(text: $searchText)
                }
            }
            ScrollView {
                if let breeds = (filterActive ? model.filteredBreedList ?? model.breedList : model.breedList) {
                    LazyVGrid(columns: columns) {
                        ForEach(breeds, id: \.id) { breed in
                            if (searchText.isEmpty || breed.breedName.lowercased().contains(searchText.lowercased())) {
                                Button(action: {
                                    if (!breed.isCaptured) {
                                        isPresentingAddBreed = breed
                                    } else {
                                        isPresentingCapturedBreed = breed
                                    }
                                }) {
                                    BreedView(breed: breed)
                                }
                            }
                        }
                        .sheet(item: $isPresentingAddBreed, onDismiss: {
                            self.refreshed.toggle()
                        }) { breed in
                            AddBreedSheetView(breed: breed)
                        }
                        .sheet(item: $isPresentingEditBreed, onDismiss: {
                            self.refreshed.toggle()
                        }) { breed in
                            AddBreedSheetView(breed: breed, isEdit: true, name: breed.details.name, dateTaken: breed.details.dateTaken, age: breed.details.age, funFact: breed.details.funFact, sex: breed.details.sex, location: breed.details.location)
                        }
                        .sheet(item: $isPresentingCapturedBreed, onDismiss: {
                            self.refreshed.toggle()
                        }) { breed in
                            CapturedSheetView(breed: breed, presignedUrl: "", isPresentingEditBreed: $isPresentingEditBreed, isPresentingCapturedBreed: $isPresentingCapturedBreed)
                        }
                    }
                    Spacer()
                }
            }
            .refreshable {
                refreshView()
            }
            .task(id: refreshed) {
                await model.fetchBreeds()
                showingSpinner = false
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .gesture(
               DragGesture().onChanged { value in
                  if value.translation.height > 0 {
                      showSearchBar = true
                  } else {
                      showSearchBar = false
                  }
               }
            )
            .task(id: filterActive) {
                if (filterActive) {
                    await model.fetchFilteredBreeds()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    filterActive.toggle()
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle\(filterActive ? ".fill" : "")")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.accentColor)
                        .padding(.trailing, 5)
                }
            }
        }
        .overlay(
            GeometryReader() { proxy in
                ZStack {
                    if (showingSpinner) {
                        ProgressView()
                            .scaleEffect(2.0)
                    }
                }.offset(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
        )
    }
}

#Preview {
    BreedPageView()
}
