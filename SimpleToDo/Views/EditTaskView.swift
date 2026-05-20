//
//  EditTaskView.swift
//  SimpleToDo
//
//  Created by Akhila Pasupunuri on 5/19/26.
//

import SwiftUI

// MARK: - Edit Task Sheet View
/// Modal form for editing existing tasks; similar to AddTaskView but with initial values and notification support
struct EditTaskView: View {
    @Binding var isPresented: Bool              // Controls sheet visibility
    let onSaveTask: (String, String, Date, Bool, Int, Int) -> Void  // Callback when changes are saved with notification params
    let isDarkMode: Bool
    
    let initialTitle: String          // Initial task title (for editing)
    let initialDescription: String    // Initial task description
    let initialDueTime: Date           // Initial task due time
    let initialNotifyBeforeEnabled: Bool       // Initial notification enabled state
    let initialNotifyBeforeHours: Int          // Initial notification hours
    let initialNotifyBeforeMinutes: Int        // Initial notification minutes
    
    @State private var title: String          // Edited title
    @State private var description: String    // Edited description
    @State private var dueTime: Date          // Edited due time
    @State private var notifyBeforeEnabled: Bool
    @State private var notifyBeforeHours: Int
    @State private var notifyBeforeMinutes: Int
    
    // MARK: - Colors
    var bgPrimary: Color { isDarkMode ? Color(red: 0.08, green: 0.08, blue: 0.12) : Color.white }
    var bgSecondary: Color { isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.18) : Color(red: 0.95, green: 0.95, blue: 0.98) }
    var textPrimary: Color { isDarkMode ? Color(red: 0.9, green: 0.8, blue: 1.0) : Color(red: 0.2, green: 0.1, blue: 0.4) }
    var textSecondary: Color { isDarkMode ? Color(red: 0.7, green: 0.7, blue: 0.8) : Color(red: 0.4, green: 0.3, blue: 0.6) }
    var accentPurple: Color { Color(red: 0.7, green: 0.5, blue: 1.0) }
    var accentRed: Color { Color(red: 1.0, green: 0.3, blue: 0.3) }
    
    init(isPresented: Binding<Bool>, onSaveTask: @escaping (String, String, Date, Bool, Int, Int) -> Void, initialTitle: String, initialDescription: String, initialDueTime: Date, initialNotifyBeforeEnabled: Bool = false, initialNotifyBeforeHours: Int = 0, initialNotifyBeforeMinutes: Int = 0, isDarkMode: Bool) {
        self._isPresented = isPresented
        self.onSaveTask = onSaveTask
        self.isDarkMode = isDarkMode
        self.initialTitle = initialTitle
        self.initialDescription = initialDescription
        self.initialDueTime = initialDueTime
        self.initialNotifyBeforeEnabled = initialNotifyBeforeEnabled
        self.initialNotifyBeforeHours = initialNotifyBeforeHours
        self.initialNotifyBeforeMinutes = initialNotifyBeforeMinutes
        _title = State(initialValue: initialTitle)
        _description = State(initialValue: initialDescription)
        _dueTime = State(initialValue: initialDueTime)
        _notifyBeforeEnabled = State(initialValue: initialNotifyBeforeEnabled)
        _notifyBeforeHours = State(initialValue: initialNotifyBeforeHours)
        _notifyBeforeMinutes = State(initialValue: initialNotifyBeforeMinutes)
    }
    
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
    /// Validates notification time is between 5 minutes and the full remaining time until expiration
    var notificationTimeInMinutes: Int {
        (notifyBeforeHours * 60) + notifyBeforeMinutes
    }
    
    var timeRemainingInMinutes: Int {
        Int(dueTime.timeIntervalSince(Date()) / 60)
    }
    
    var minAllowedNotificationMinutes: Int {
        5 // Minimum 5 minutes before expiration
    }
    
    var maxAllowedNotificationMinutes: Int {
        timeRemainingInMinutes // Maximum is the full remaining time
    }
    
    var notificationTimeIsValid: Bool {
        guard notifyBeforeEnabled else { return true }
        return notificationTimeInMinutes >= minAllowedNotificationMinutes && notificationTimeInMinutes <= maxAllowedNotificationMinutes
    }
    
    var notificationErrorMessage: String {
        if notificationTimeInMinutes < minAllowedNotificationMinutes {
            return "Notification must be at least 5 minutes before task expiration"
        } else if notificationTimeInMinutes > maxAllowedNotificationMinutes {
            let maxHours = maxAllowedNotificationMinutes / 60
            let maxMinutes = maxAllowedNotificationMinutes % 60
            return "Notification time exceeds available time. Max: \(maxHours)h \(maxMinutes)m"
        }
        return ""
    }
    
    var body: some View {
        ZStack {
            bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    // MARK: - Edit Task Header
                    Text("Edit Task")
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
                
                // MARK: - Title Input Field (Edit)
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
                
                // MARK: - Description Input Field with Character Limit (Edit)
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
                
                // MARK: - Due Time Picker (Edit)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Due Time")
                        .font(.system(size: 12, weight: .semibold, design: .default))
                        .foregroundColor(isDarkMode ? Color(red: 0.8, green: 0.8, blue: 0.9) : Color(red: 0.3, green: 0.2, blue: 0.5))
                    
                    DatePicker("", selection: $dueTime, in: minDueTime...maxDueTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .frame(height: 120)
                        .preferredColorScheme(isDarkMode ? .dark : .light)
                }
                
                // MARK: - Notification Preferences (Edit)
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
                
                // MARK: - Save Changes Action Button
                /// Disabled until form is valid; updates task and closes sheet
                Button(action: {
                    onSaveTask(title, description, dueTime, notifyBeforeEnabled, notifyBeforeHours, notifyBeforeMinutes)
                    isPresented = false
                }) {
                    Text("Save Changes")
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
