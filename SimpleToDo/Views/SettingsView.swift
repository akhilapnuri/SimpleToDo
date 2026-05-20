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
    
    var bgPrimary: Color {
        isDarkMode ? Color(red: 0.08, green: 0.08, blue: 0.12) : Color.white
    }
    
    var textPrimary: Color {
        isDarkMode ? Color(red: 0.9, green: 0.8, blue: 1.0) : Color(red: 0.2, green: 0.1, blue: 0.4)
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
                
                Spacer()
            }
            .padding(20)
        }
    }
}
