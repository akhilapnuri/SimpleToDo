//
//  AddTaskView.swift
//  SimpleToDo
//
//  Created by Akhila Pasupunuri on 5/19/26.
//

import SwiftUI

// MARK: - Add Task Sheet View
/// Modal form for creating new tasks with title, description, due time picker, and notification preferences
struct AddTaskView: View {
    @Binding var isPresented: Bool              // Controls sheet visibility
    let onAddTask: (String, String, Date, Bool, Int, Int) -> Void  // Callback when task is created with notification params
    let isDarkMode: Bool
    
    @State private var title = ""              // New task title
    @State private var description = ""        // New task description (max 50 chars)
    // MARK: - Default Due Time: Today at 11:59 PM
    /// When a new task is created, default due time is set to 11:59 PM today
    @State private var dueTime = {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 23
        components.minute = 59
        components.second = 0
        return calendar.date(from: components) ?? Date()
    }()
    @State private var notifyBeforeEnabled = false
    @State private var notifyBeforeHours = 0
    @State private var notifyBeforeMinutes = 0
    
    // MARK: - Colors
    var bgPrimary: Color { isDarkMode ? Color(red: 0.08, green: 0.08, blue: 0.12) : Color.white }
    var bgSecondary: Color { isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.18) : Color(red: 0.95, green: 0.95, blue: 0.98) }
    var textPrimary: Color { isDarkMode ? Color(red: 0.9, green: 0.8, blue: 1.0) : Color(red: 0.2, green: 0.1, blue: 0.4) }
    var textSecondary: Color { isDarkMode ? Color(red: 0.7, green: 0.7, blue: 0.8) : Color(red: 0.4, green: 0.3, blue: 0.6) }
    var accentPurple: Color { Color(red: 0.7, green: 0.5, blue: 1.0) }
    var accentRed: Color { Color(red: 1.0, green: 0.3, blue: 0.3) }
    
    var minDueTime: Date {
        Date()
    }
    
    var maxDueTime: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 23
        components.minute = 59
        components.second = 0
        return calendar.date(from: components) ?? Date()
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Notification Time Validation
    /// Validates that notification time doesn't exceed time left until expiration minus 5 minutes
    var notificationTimeInMinutes: Int {
        (notifyBeforeHours * 60) + notifyBeforeMinutes
    }
    
    var timeRemainingInMinutes: Int {
        Int(dueTime.timeIntervalSince(Date()) / 60)
    }
    
    var maxAllowedNotificationMinutes: Int {
        max(0, timeRemainingInMinutes - 5)
    }
    
    var notificationTimeIsValid: Bool {
        !notifyBeforeEnabled || notificationTimeInMinutes <= maxAllowedNotificationMinutes
    }
    
    var notificationErrorMessage: String {
        let maxHours = maxAllowedNotificationMinutes / 60
        let maxMinutes = maxAllowedNotificationMinutes % 60
        return "Notification time exceeds available time. Max: \(maxHours)h \(maxMinutes)m"
    }
    
    var body: some View {
        ZStack {
            bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("New Task")
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(textPrimary)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(accentPurple)
                    }
                }
                .padding(.bottom, 10)
                
                // MARK: - Title Input Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.system(size: 12, weight: .semibold, design: .default))
                        .foregroundColor(isDarkMode ? Color(red: 0.8, green: 0.8, blue: 0.9) : Color(red: 0.3, green: 0.2, blue: 0.5))
                    
                    TextField("Enter task title", text: $title)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(12)
                        .background(bgSecondary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(accentPurple.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // MARK: - Description Input Field with Character Count
                /// Limits description to 50 characters with live counter display
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Description")
                            .font(.system(size: 12, weight: .semibold, design: .default))
                            .foregroundColor(isDarkMode ? Color(red: 0.8, green: 0.8, blue: 0.9) : Color(red: 0.3, green: 0.2, blue: 0.5))
                        
                        Spacer()
                        
                        Text("\(description.count)/50")
                            .font(.system(size: 11, weight: .regular, design: .default))
                            .foregroundColor(accentPurple)
                    }
                    
                    TextField("Enter task description", text: $description)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(12)
                        .background(bgSecondary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(accentPurple.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: description) { newValue in
                            if newValue.count > 50 {
                                description = String(newValue.prefix(50))
                            }
                        }
                }
                
                // MARK: - Due Time Picker
                /// Wheel-style DatePicker limited to today (can only set time, not date)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Due Time")
                        .font(.system(size: 12, weight: .semibold, design: .default))
                        .foregroundColor(isDarkMode ? Color(red: 0.8, green: 0.8, blue: 0.9) : Color(red: 0.3, green: 0.2, blue: 0.5))
                    
                    DatePicker("", selection: $dueTime, in: minDueTime...maxDueTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .frame(height: 120)
                        .preferredColorScheme(isDarkMode ? .dark : .light)
                }
                
                // MARK: - Notification Preferences
                /// Toggle and time inputs for notification before task expiration
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Notify Before")
                            .font(.system(size: 12, weight: .semibold, design: .default))
                            .foregroundColor(isDarkMode ? Color(red: 0.8, green: 0.8, blue: 0.9) : Color(red: 0.3, green: 0.2, blue: 0.5))
                        
                        Spacer()
                        
                        Toggle("", isOn: $notifyBeforeEnabled)
                            .tint(accentPurple)
                    }
                    
                    if notifyBeforeEnabled {
                        HStack(spacing: 12) {
                            // Hours input
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Hours")
                                    .font(.system(size: 11, weight: .regular, design: .default))
                                    .foregroundColor(textSecondary)
                                
                                TextField("0", value: $notifyBeforeHours, format: .number)
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(isDarkMode ? .white : .black)
                                    .keyboardType(.numberPad)
                                    .padding(10)
                                    .background(bgSecondary)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(accentPurple.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            // Minutes input
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Minutes")
                                    .font(.system(size: 11, weight: .regular, design: .default))
                                    .foregroundColor(textSecondary)
                                
                                TextField("0", value: $notifyBeforeMinutes, format: .number)
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(isDarkMode ? .white : .black)
                                    .keyboardType(.numberPad)
                                    .padding(10)
                                    .background(bgSecondary)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(accentPurple.opacity(0.3), lineWidth: 1)
                                    )
                                    .onChange(of: notifyBeforeMinutes) { newValue in
                                        // Clamp minutes to 0-59
                                        if newValue > 59 {
                                            notifyBeforeMinutes = 59
                                        } else if newValue < 0 {
                                            notifyBeforeMinutes = 0
                                        }
                                    }
                            }
                            
                            Spacer()
                        }
                        
                        // Validation error message
                        if !notificationTimeIsValid {
                            Text(notificationErrorMessage)
                                .font(.system(size: 11, weight: .regular, design: .default))
                                .foregroundColor(accentRed)
                                .lineLimit(2)
                        }
                    }
                }
                
                Spacer()
                
                // MARK: - Create Task Action Button
                /// Disabled until form is valid; saves task and closes sheet
                Button(action: {
                    onAddTask(title, description, dueTime, notifyBeforeEnabled, notifyBeforeHours, notifyBeforeMinutes)
                    isPresented = false
                }) {
                    Text("Append Task")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(isDarkMode ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(isDarkMode ? Color.white : accentPurple)
                        .cornerRadius(12)
                        .shadow(color: accentPurple.opacity(0.6), radius: 16, x: 0, y: 0)
                }
                .disabled(!isFormValid || !notificationTimeIsValid)
                .opacity((isFormValid && notificationTimeIsValid) ? 1 : 0.5)
            }
            .padding(20)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}
