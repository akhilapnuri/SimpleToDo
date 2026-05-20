//
//  TaskBarView.swift
//  SimpleToDo
//
//  Created by Akhila Pasupunuri on 5/19/26.
//

import SwiftUI
import Combine

// MARK: - Task Bar View
/// Individual task card with swipe-to-reveal delete/edit buttons, overdue detection, and animations
struct TaskBarView: View {
    let task: Task
    let onToggle: () -> Void      // Callback when task completion is toggled
    let onEdit: () -> Void        // Callback when edit button is tapped
    let onDelete: () -> Void      // Callback when task is confirmed for deletion
    let isDarkMode: Bool
    
    @State private var showDeleteConfirmation = false   // Confirmation dialog for deletion
    @State private var offset: CGFloat = 0              // X-position offset for swipe reveal animation
    @State private var currentDrag: CGFloat = 0         // Real-time drag translation with rubber band effect
    @State private var currentTime = Date()             // Updated every 30 seconds for overdue detection
    
    // MARK: - Swipe-to-Reveal Configuration
    private let revealThreshold: CGFloat = -40        // Swipe distance to trigger reveal
    private let revealDistance: CGFloat = -160        // Full reveal distance for delete/edit buttons
    private let rubberBandFactor: CGFloat = 0.3       // Resistance factor for overshoot animation
    
    // MARK: - Color Scheme
    var bgSecondary: Color {
        isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.18) : Color(red: 0.95, green: 0.95, blue: 0.98)
    }
    
    var textPrimary: Color {
        isDarkMode ? Color(red: 0.9, green: 0.8, blue: 1.0) : Color(red: 0.2, green: 0.1, blue: 0.4)
    }
    
    var textSecondary: Color {
        isDarkMode ? Color(red: 0.7, green: 0.7, blue: 0.8) : Color(red: 0.4, green: 0.3, blue: 0.6)
    }
    
    var textCompleted: Color {
        isDarkMode ? Color(red: 0.6, green: 0.6, blue: 0.7) : Color(red: 0.5, green: 0.4, blue: 0.6)
    }
    
    var accentPurple: Color {
        Color(red: 0.7, green: 0.5, blue: 1.0)
    }
    
    var accentRed: Color {
        Color(red: 1.0, green: 0.3, blue: 0.3)
    }
    
    // MARK: - Overdue Detection Feature
    /// Returns true if task is incomplete and past due time (updates every 30 seconds)
    var isOverdue: Bool {
        !task.isCompleted && task.dueTime < currentTime
    }
    
    var dueTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: task.dueTime)
    }
    
    // MARK: - Rubber Band Animation Helper
    /// Calculates smooth rubber band effect for swipe: resistance increases as user overshoots
    private func getRubberBandOffset(_ translation: CGFloat) -> CGFloat {
        if translation >= 0 {
            return 0
        }
        if translation >= revealThreshold {
            return translation
        }
        let excess = translation - revealThreshold
        return revealThreshold + (excess * rubberBandFactor)
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                // Task card content (left side: title, description, due time)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // MARK: - Task Completion Toggle Button
                        /// Click to toggle task between complete/incomplete status
                        Button(action: onToggle) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(task.isCompleted ? accentPurple : textSecondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(task.title)
                                .font(.system(size: 14, weight: .semibold, design: .default))
                                .foregroundColor(task.isCompleted ? textCompleted : textPrimary)
                                .strikethrough(task.isCompleted, color: textCompleted)
                            
                            Text(task.description)
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundColor(textSecondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // MARK: - Overdue Indicator: Due Time with Color Transition
                        /// Changes from purple to red with glow effect when task becomes overdue
                        Text(dueTimeString)
                            .font(.system(size: 11, weight: .regular, design: .default))
                            .foregroundColor(isOverdue ? accentRed : accentPurple)
                            .shadow(color: isOverdue ? accentRed.opacity(0.8) : accentPurple.opacity(0.4), radius: isOverdue ? 4 : 4, x: 0, y: 0)
                            .shadow(color: isOverdue ? accentRed.opacity(0.5) : Color.clear, radius: 10, x: 0, y: 0)
                            .shadow(color: isOverdue ? accentRed.opacity(0.3) : Color.clear, radius: 18, x: 0, y: 0)
                            .animation(.easeInOut(duration: 0.5), value: isOverdue)
                    }
                }
                .frame(width: geo.size.width)
                .padding(12)
                .background(bgSecondary)
                .cornerRadius(10)
                // MARK: - Overdue Border Glow Effect
                /// Red border with multi-layer shadow appears when task becomes overdue
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(accentRed, lineWidth: 1)
                        .shadow(color: accentRed.opacity(0.8), radius: 4, x: 0, y: 0)
                        .shadow(color: accentRed.opacity(0.5), radius: 10, x: 0, y: 0)
                        .shadow(color: accentRed.opacity(0.3), radius: 18, x: 0, y: 0)
                        .opacity(isOverdue ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: isOverdue)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    accentPurple.opacity(0.4),
                                    Color(red: 0.5, green: 0.7, blue: 0.95).opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .opacity(isOverdue ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5), value: isOverdue)
                )
                
                // Spacing buffer so buttons don't show through padding
                Color.clear.frame(width: 20)
                
                // MARK: - Swipe-to-Reveal Delete/Edit Buttons
                /// Hidden buttons slide in from right when user swipes left on task card
                HStack(spacing: 8) {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 60, height: 60)
                    .background(accentPurple)
                    .cornerRadius(10)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            offset = 0
                        }
                        onEdit()
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 60, height: 60)
                    .background(accentPurple)
                    .cornerRadius(10)
                    
                    Spacer().frame(width: 8)
                }
            }
            .frame(height: 70)
            .offset(x: offset + currentDrag)
            .clipped()
            .contentShape(Rectangle())
            // MARK: - Horizontal Swipe Gesture (Swipe-to-Reveal)
            /// Detects left/right swipes while allowing vertical scrolling to pass through
            /// Uses directional detection to distinguish horizontal swipes from vertical scrolls
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        let horizontalDelta = abs(value.translation.width)
                        let verticalDelta = abs(value.translation.height)
                        // Only respond if horizontal movement is at least 2x the vertical movement (prevents scroll interference)
                        if horizontalDelta > verticalDelta * 2 && horizontalDelta > 5 {
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                                currentDrag = getRubberBandOffset(value.translation.width)
                            }
                        }
                    }
                    .onEnded { value in
                        let horizontalDelta = abs(value.translation.width)
                        let verticalDelta = abs(value.translation.height)
                        if horizontalDelta > verticalDelta * 2 && horizontalDelta > 5 {
                            let totalTranslation = value.translation.width + offset
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.2)) {
                                if totalTranslation < revealThreshold {
                                    offset = revealDistance
                                } else {
                                    offset = 0
                                }
                                currentDrag = 0
                            }
                        } else {
                            currentDrag = 0
                        }
                    }
            )
        }
        .frame(height: 70)
        .padding(.trailing, 20)
        // MARK: - Overdue Timer: Updates Every 30 Seconds
        /// Refreshes currentTime every 30 seconds to detect when tasks become overdue
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { _ in
            currentTime = Date()
        }
        .confirmationDialog(
            "Delete Task",
            isPresented: $showDeleteConfirmation,
            actions: {
                Button("Delete", role: .destructive) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        offset = 0
                    }
                    onDelete()
                }
                Button("Cancel", role: .cancel) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        offset = 0
                    }
                }
            },
            message: {
                Text("Are you sure you want to delete this task? This action cannot be undone.")
            }
        )
    }
}
