//
//  SettingsView.swift
//  SimpleToDo
//
//  Created by Akhila Pasupunuri on 5/19/26.
//

import SwiftUI

// MARK: - Settings Sheet View
/// Lightweight settings modal with dark/light mode toggle
struct SettingsView: View {
    @Binding var isPresented: Bool     // Controls sheet visibility
    @Binding var isDarkMode: Bool      // Two-way binding to persist mode across app
    @AppStorage("taskSortBy") private var sortBy: String = "Date Added"
    @AppStorage("taskSortDirection") private var sortDirection: String = "Ascending"
    
    var bgPrimary: Color {
        isDarkMode ? Color(red: 0.08, green: 0.08, blue: 0.12) : Color.white
    }
    
    var textPrimary: Color {
        isDarkMode ? Color(red: 0.9, green: 0.8, blue: 1.0) : Color(red: 0.2, green: 0.1, blue: 0.4)
    }
    
    var textSecondary: Color {
        isDarkMode ? Color(red: 0.7, green: 0.7, blue: 0.8) : Color(red: 0.4, green: 0.3, blue: 0.6)
    }
    
    var accentPurple: Color {
        Color(red: 0.7, green: 0.5, blue: 1.0)
    }
    
    var body: some View {
        ZStack {
            bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("Settings")
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
                
                // MARK: - Dark Mode Toggle Feature
                /// Switches between light and dark color schemes; persists via @AppStorage
                HStack {
                    Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                        .font(.system(size: 18))
                        .foregroundColor(accentPurple)
                    
                    Text(isDarkMode ? "Dark Mode" : "Light Mode")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(textPrimary)
                    
                    Spacer()
                    
                    Toggle("", isOn: $isDarkMode)
                        .tint(accentPurple)
                }
                .padding(16)
                .background(isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.18) : Color(red: 0.95, green: 0.95, blue: 0.98))
                .cornerRadius(10)
                
                // MARK: - Sort Tasks Feature
                /// Grouped button picker for sort options and direction toggle
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sort tasks by")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundColor(textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    // Sort by options
                    Picker("Sort by", selection: $sortBy) {
                        Text("Date Added").tag("Date Added")
                        Text("Due Time").tag("Due Time")
                        Text("A to Z").tag("A to Z")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .tint(accentPurple)
                    
                    // Sort direction toggle
                    HStack(spacing: 8) {
                        Button(action: { sortDirection = "Ascending" }) {
                            Text("Ascending")
                                .font(.system(size: 14, weight: .semibold, design: .default))
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(sortDirection == "Ascending" ? accentPurple : Color.clear)
                                .foregroundColor(sortDirection == "Ascending" ? Color.white : textPrimary)
                                .cornerRadius(8)
                        }
                        
                        Button(action: { sortDirection = "Descending" }) {
                            Text("Descending")
                                .font(.system(size: 14, weight: .semibold, design: .default))
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(sortDirection == "Descending" ? accentPurple : Color.clear)
                                .foregroundColor(sortDirection == "Descending" ? Color.white : textPrimary)
                                .cornerRadius(8)
                        }
                    }
                    .padding(16)
                }
                .background(isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.18) : Color(red: 0.95, green: 0.95, blue: 0.98))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding(20)
        }
    }
}
