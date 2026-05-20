//
//  Task.swift
//  SimpleToDo
//
//  Created by Akhila Pasupunuri on 5/19/26.
//

import Foundation

// MARK: - Task Model
/// Represents a single task with title, description, due time, completion status, and notification preferences
/// Conforms to Identifiable (for List views), Codable (for persistence), and Equatable (for animations)
struct Task: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let dueTime: Date
    var isCompleted: Bool = false
    var notifyBeforeEnabled: Bool = false
    var notifyBeforeHours: Int = 0
    var notifyBeforeMinutes: Int = 0
    
    init(id: UUID = UUID(), title: String, description: String, dueTime: Date, isCompleted: Bool = false, notifyBeforeEnabled: Bool = false, notifyBeforeHours: Int = 0, notifyBeforeMinutes: Int = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.dueTime = dueTime
        self.isCompleted = isCompleted
        self.notifyBeforeEnabled = notifyBeforeEnabled
        self.notifyBeforeHours = notifyBeforeHours
        self.notifyBeforeMinutes = notifyBeforeMinutes
    }
}
