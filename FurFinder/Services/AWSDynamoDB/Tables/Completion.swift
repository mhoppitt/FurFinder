//
//  Completion.swift
//  FurFinder
//
//  Created by Matt Hoppitt on 17/1/2025.
//

import Foundation

public struct Completion: Codable {
    var completionRate: Float
    var completed: Int
    var total: Int
    
    init(completionRate: Float, completed: Int, total: Int) {
        self.completionRate = completionRate
        self.completed = completed
        self.total = total
    }
}
