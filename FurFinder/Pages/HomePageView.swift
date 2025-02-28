//
//  HomePageView.swift
//  FurFinder
//
//  Created by Matt Hoppitt on 6/1/2025.
//

import SwiftUI

struct HomePageView: View {
    var breedsService = BreedsService()
    
    @State var completion: Completion = Completion(completionRate: "0.00", completed: 0, total: 0)
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image(String("HomePageImage"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 275, height: 275)
                Spacer()
                Text("Snap, Wag, Repeat")
                    .font(.system(size: 60))
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                Text("Discover and document your furry finds!")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                Spacer()
                NavigationLink(destination: BreedPageView()) {
                    Text("Next")
                        .bold()
                        .padding(10)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                }
                .font(.title)
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .clipShape(.rect(cornerRadius: 30))
                Spacer()
                if (completion.completionRate == "0.00") {
                    Spacer()
                } else {
                    VStack {
                        Text("\(completion.completed)/\(completion.total)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 10)
                        Text("Completed \(completion.completionRate)%")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 10)
                    }
                }
            }
            .padding()
            .task {
                do {
                    completion = try await breedsService.getCompletionRate()
                } catch {
                   print("Message update failed.")
                }
            }
        }
    }
}

#Preview {
    HomePageView(completion: Completion(completionRate: "20.00", completed: 1, total: 5))
}
