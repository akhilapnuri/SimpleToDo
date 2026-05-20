//
//  TaskViewModel.swift
//  SimpleToDo
//
//  Created by Akhila Pasupunuri on 5/19/26.
//

import Foundation
import Combine

// MARK: - Task View Model
/// Manages task data, persistence to UserDefaults, and daily task reset logic
class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    private let tasksKey = "savedTasks"
    private let lastSaveDateKey = "lastSaveDate"
    
    init() {
        loadTasks()
    }
    
    // MARK: - Persistence Feature: Save Tasks to UserDefaults
    /// Encodes tasks array to JSON and stores in UserDefaults with current timestamp
    func saveTasks() {
        do {
            let encoded = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(encoded, forKey: tasksKey)
            UserDefaults.standard.set(Date(), forKey: lastSaveDateKey)
        } catch {
            print("Error saving tasks: \(error)")
        }
    }
    
    // MARK: - Persistence & Daily Reset Feature: Load Tasks from UserDefaults
    /// Loads tasks from UserDefaults; resets tasks if a new day has started (daily task refresh)
    func loadTasks() {
        // Check if we need to reset tasks (new day)
        let today = Calendar.current.startOfDay(for: Date())
        if let lastSaveDate = UserDefaults.standard.object(forKey: lastSaveDateKey) as? Date {
            let lastSaveDay = Calendar.current.startOfDay(for: lastSaveDate)
            if lastSaveDay != today {
                // Different day, reset tasks
                tasks = []
                UserDefaults.standard.set(today, forKey: lastSaveDateKey)
                return
            }
        } else {
            // First time, set today's date
            UserDefaults.standard.set(today, forKey: lastSaveDateKey)
        }
        
        guard let savedData = UserDefaults.standard.data(forKey: tasksKey) else {
            tasks = []
            return
        }
        
        do {
            tasks = try JSONDecoder().decode([Task].self, from: savedData)
        } catch {
            print("Error loading tasks: \(error)")
            tasks = []
        }
    }
}
