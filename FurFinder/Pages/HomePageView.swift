//
//  HomePageView.swift
//  FurFinder
//
//  Created by Matt Hoppitt on 6/1/2025.
//

import SwiftUI

struct HomePageView: View {
    var breedsService = BreedsService()
    
    @State var completion: Completion = Completion(completionRate: 0.00, completed: 0, total: 0)
    
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
                        .padding(.leading, 30)
                        .padding(.trailing, 30)
                }
                .font(.title)
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .clipShape(.rect(cornerRadius: 30))
                Spacer()
                if (completion.completionRate == 0.00) {
                    Spacer()
                } else {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            ProgressView(value: completion.completionRate)
                                .scaleEffect(x: 1, y: 1.5)
                            Text("\(completion.completed)/\(completion.total) (\(String(format: "%.2f", completion.completionRate * 100))%)")
                                .foregroundColor(.secondary)
                            
                        }
                        Spacer()
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
    HomePageView(completion: Completion(completionRate: 0.2, completed: 1, total: 5))
}
