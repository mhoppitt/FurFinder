//
//  FurFinderBreed.swift
//  FurFinder
//
//  Created by Matt Hoppitt on 6/1/2025.
//

import Foundation

public struct FurFinderBreed: Codable, Identifiable, Hashable {
    
    public var id: String
    var breedName: String
    var isCaptured: Bool
    var details: DogDetails
    
    init(id: String, breedName: String, isCaptured: Bool, details: DogDetails) {
        self.id = id
        self.breedName = breedName
        self.isCaptured = isCaptured
        self.details = details
    }
}

public struct DogDetails: Codable, Identifiable, Hashable {
    public var id: String
    var name: String
    var dateTaken: Date
    var age: String
    var funFact: String
    var sex: String
    var location: String
    
    init(id: String, name: String, dateTaken: Date, age: String, funFact: String, sex: String, location: String) {
        self.id = id
        self.name = name
        self.dateTaken = dateTaken
        self.age = age
        self.funFact = funFact
        self.sex = sex
        self.location = location
    }
}
