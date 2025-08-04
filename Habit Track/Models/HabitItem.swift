//
//  HabitItem.swift
//  Habit Track
//
//  Created by Nikolay Simeonov on 13.07.25.
//

import Foundation
import SwiftData

@Model
class HabitItem: Identifiable {
    var id: UUID
    var emoji: String
    var title: String
    var habitDescription: String
    var completionDates: [Date]

    init(id: UUID = UUID(), emoji: String, title: String, description: String, completionDates: [Date] = []) {
        self.id = id
        self.emoji = emoji
        self.title = title
        self.habitDescription = description
        self.completionDates = completionDates
    }
}
