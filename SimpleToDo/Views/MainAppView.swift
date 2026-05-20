//
//  MainAppView.swift
//  SimpleToDo
//
//  Created by Akhila Pasupunuri on 5/18/26.
//

import SwiftUI

// MARK: - Main App View
/// Primary view displaying task list, progress chart, and tab switcher
/// Features: scrollable task list, donut progress chart, tab-based filtering, dark/light mode
struct MainAppView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showAddTaskSheet = false      // Controls New Task sheet visibility
    @State private var showSettingsSheet = false     // Controls Settings sheet visibility
    @State private var editingTask: Task? = nil      // Tracks which task is being edited
    @State private var selectedTab = 0               // 0 = My Tasks, 1 = Completed (for tab filtering)
    @Namespace private var underlineNamespace        // For animated tab underline effect
    @AppStorage("isDarkMode") private var isDarkMode = true  // Persistent dark/light mode
    
    // MARK: - Color Scheme (Environment-Aware: Light/Dark Mode)
    /// All colors adapt to isDarkMode for consistent dark/light mode support
    var bgPrimary: Color {
        isDarkMode ? Color(red: 0.08, green: 0.08, blue: 0.12) : Color.white
    }
    
    var bgSecondary: Color {
        isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.18) : Color(red: 0.95, green: 0.95, blue: 0.98)
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
    
    var accentRed: Color {
        Color(red: 1.0, green: 0.3, blue: 0.3)
    }
    
    var progressGradientStart: Color {
        isDarkMode ? accentPurple : Color(red: 0.55, green: 0.25, blue: 0.95)
    }
    
    var progressGradientEnd: Color {
        isDarkMode ? Color(red: 0.5, green: 0.7, blue: 0.95) : Color(red: 0.8, green: 0.6, blue: 1.0)
    }
    
    var glowGradientStart: Color {
        isDarkMode ? accentPurple.opacity(0.3) : Color(red: 0.7, green: 0.5, blue: 1.0).opacity(0.15)
    }
    
    var glowGradientMid: Color {
        isDarkMode ? Color(red: 0.5, green: 0.3, blue: 0.9).opacity(0.1) : Color(red: 0.8, green: 0.6, blue: 1.0).opacity(0.05)
    }
    
    var progressShadowPrimary: Color {
        isDarkMode ? accentPurple.opacity(0.8) : Color(red: 0.85, green: 0.75, blue: 1.0).opacity(0.3)
    }
    
    var progressShadowSecondary: Color {
        isDarkMode ? Color(red: 0.5, green: 0.3, blue: 0.9).opacity(0.6) : Color(red: 0.9, green: 0.8, blue: 1.0).opacity(0.15)
    }
    
    var tasks: [Task] {
        viewModel.tasks
    }
    
    // MARK: - Tab Filtering Feature: My Tasks vs Completed
    /// Filters tasks based on selectedTab: 0 = incomplete tasks, 1 = completed tasks
    var filteredTasks: [Task] {
        if selectedTab == 0 {
            return viewModel.tasks.filter { !$0.isCompleted }
        } else {
            return viewModel.tasks.filter { $0.isCompleted }
        }
    }
    
    var tasksCompleted: Int {
        viewModel.tasks.filter { $0.isCompleted }.count
    }
    
    var totalTasks: Int {
        viewModel.tasks.count
    }
    
    // MARK: - Progress Chart Feature: Completion Percentage
    /// Calculates percentage of completed tasks (0-1) for donut chart visualization
    var progressPercentage: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(tasksCompleted) / Double(totalTasks)
    }
    
    var body: some View {
        ZStack {
            bgPrimary
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    // MARK: - Top Navigation Bar
                    /// Header with app title, settings button, and add task button
                    HStack {
                        Text("One Focus")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(accentPurple)
                            .shadow(color: accentPurple.opacity(0.6), radius: 8, x: 0, y: 0)
                        
                        Spacer()
                        
                        Button(action: { showSettingsSheet = true }) {
                            Image(systemName: "gear.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(accentPurple)
                                .shadow(color: accentPurple.opacity(0.8), radius: 12, x: 0, y: 0)
                        }
                        
                        Button(action: { showAddTaskSheet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(accentPurple)
                                .shadow(color: accentPurple.opacity(0.8), radius: 12, x: 0, y: 0)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    // MARK: - Donut Progress Chart Feature
                    /// Circular progress visualization with animated gradient and percentage text
                    VStack(spacing: 12) {
                        ZStack {
                            // Background circle
                            Circle()
                                .stroke(isDarkMode ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color(red: 0.85, green: 0.85, blue: 0.9), lineWidth: 20)
                                .frame(width: 180, height: 180)
                            
                            // Radial glow background
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    glowGradientStart,
                                    glowGradientMid,
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                            .frame(width: 220, height: 220)
                            
                            // Progress circle
                            Circle()
                                .trim(from: 0, to: progressPercentage)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            progressGradientStart,
                                            progressGradientEnd
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .frame(width: 180, height: 180)
                                .rotationEffect(.degrees(-90))
                                .shadow(color: progressShadowPrimary, radius: 12, x: 0, y: 0)
                                .shadow(color: progressShadowSecondary, radius: 24, x: 0, y: 0)
                                .animation(.easeInOut(duration: 0.8), value: progressPercentage)
                            
                            // Center percentage text inside donut
                            VStack(spacing: 4) {
                                Text("\(Int(progressPercentage * 100))%")
                                    .font(.system(size: 32, weight: .bold, design: .default))
                                    .foregroundColor(accentPurple)
                                    .shadow(color: accentPurple.opacity(0.8), radius: 8, x: 0, y: 0)
                                
                                Text("Complete")
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .foregroundColor(textSecondary)
                            }
                        }
                        
                        // MARK: - Tab Switcher Feature: My Tasks / Completed
                        /// Two-tab interface with animated underline to show active tab
                        HStack(spacing: 0) {
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedTab = 0
                                    }
                                }) {
                                    Text("My Tasks")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(isDarkMode ? Color(red: 0.8, green: 0.8, blue: 0.9) : Color(red: 0.3, green: 0.2, blue: 0.5))
                                }
                                .opacity(selectedTab == 0 ? 1 : 0.5)
                                
                                if selectedTab == 0 {
                                    Capsule()
                                        .frame(height: 2)
                                        .foregroundColor(accentPurple.opacity(0.4))
                                        .matchedGeometryEffect(id: "underline", in: underlineNamespace)
                                }
                            }
                            .fixedSize(horizontal: true, vertical: false)
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedTab = 1
                                    }
                                }) {
                                    Text("Completed")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(isDarkMode ? Color(red: 0.8, green: 0.8, blue: 0.9) : Color(red: 0.3, green: 0.2, blue: 0.5))
                                }
                                .opacity(selectedTab == 1 ? 1 : 0.5)
                                
                                if selectedTab == 1 {
                                    Capsule()
                                        .frame(height: 2)
                                        .foregroundColor(accentPurple.opacity(0.4))
                                        .matchedGeometryEffect(id: "underline", in: underlineNamespace)
                                }
                            }
                            .fixedSize(horizontal: true, vertical: false)
                            
                            Spacer()
                        }
                        .shadow(color: Color.white.opacity(0.4), radius: 4, x: 0, y: 0)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                        .frame(height: 16)
                    
                    // MARK: - Tasks List Feature
                    /// Vertical task list that shows/hides based on selected tab (My Tasks or Completed)
                    VStack(spacing: 10) {
                        ForEach(filteredTasks) { task in
                            TaskBarView(
                                task: task,
                                onToggle: {
                                    if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                                        viewModel.tasks[index].isCompleted.toggle()
                                        viewModel.saveTasks()
                                    }
                                },
                                onEdit: {
                                    editingTask = task
                                },
                                onDelete: {
                                    viewModel.tasks.removeAll { $0.id == task.id }
                                    viewModel.saveTasks()
                                },
                                isDarkMode: isDarkMode
                            )
                        }
                        Spacer().frame(height: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .animation(.easeInOut(duration: 0.3), value: filteredTasks)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView(isPresented: $showSettingsSheet, isDarkMode: $isDarkMode)
        }
        .sheet(isPresented: $showAddTaskSheet) {
            AddTaskView(
                isPresented: $showAddTaskSheet,
                onAddTask: { title, description, dueTime, notifyBeforeEnabled, notifyBeforeHours, notifyBeforeMinutes in
                    let newTask = Task(
                        title: title,
                        description: description,
                        dueTime: dueTime,
                        notifyBeforeEnabled: notifyBeforeEnabled,
                        notifyBeforeHours: notifyBeforeHours,
                        notifyBeforeMinutes: notifyBeforeMinutes
                    )
                    viewModel.tasks.append(newTask)
                    viewModel.saveTasks()
                },
                isDarkMode: isDarkMode
            )
        }
        .sheet(item: $editingTask) { task in
            EditTaskView(
                isPresented: Binding(
                    get: { editingTask != nil },
                    set: { if !$0 { editingTask = nil } }
                ),
                onSaveTask: { title, description, dueTime, notifyBeforeEnabled, notifyBeforeHours, notifyBeforeMinutes in
                    if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                        viewModel.tasks[index] = Task(
                            id: task.id,
                            title: title,
                            description: description,
                            dueTime: dueTime,
                            isCompleted: viewModel.tasks[index].isCompleted,
                            notifyBeforeEnabled: notifyBeforeEnabled,
                            notifyBeforeHours: notifyBeforeHours,
                            notifyBeforeMinutes: notifyBeforeMinutes
                        )
                        viewModel.saveTasks()
                    }
                    editingTask = nil
                },
                initialTitle: task.title,
                initialDescription: task.description,
                initialDueTime: task.dueTime,
                initialNotifyBeforeEnabled: task.notifyBeforeEnabled,
                initialNotifyBeforeHours: task.notifyBeforeHours,
                initialNotifyBeforeMinutes: task.notifyBeforeMinutes,
                isDarkMode: isDarkMode
            )
        }
    }
}

#Preview {
    MainAppView()
}
