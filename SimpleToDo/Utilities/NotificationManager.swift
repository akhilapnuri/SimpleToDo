//
//  NotificationManager.swift
//  SimpleToDo
//
//  Created by Akhila Pasupunuri on 5/19/26.
//

import Foundation
import UIKit
import UserNotifications

// MARK: - Notification Manager
/// Handles scheduling, managing, and cancelling local push notifications for task reminders
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Handle Notifications in Foreground
    /// This delegate method handles notifications when the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Display notification even when app is in foreground
        let options: UNNotificationPresentationOptions = [.banner, .sound, .badge]
        completionHandler(options)
    }
    
    // MARK: - Handle Notification Tap
    /// This delegate method handles when user taps a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let taskId = userInfo["taskId"] as? String {
            print("Notification tapped for task: \(taskId)")
        }
        completionHandler()
    }
    
    // MARK: - Request Notification Permission
    /// Requests user permission for sending notifications
    /// Should be called on app launch
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Schedule Notification for Task
    /// Schedules a notification for a specific task based on notifyBefore settings
    /// Uses calendar-based trigger for reliable scheduling
    /// - Parameter task: The task to schedule a notification for
    func scheduleNotification(for task: Task) {
        // Only schedule if notify before is enabled
        guard task.notifyBeforeEnabled else {
            print("⏭️ Notify before not enabled for task: \(task.title)")
            return
        }
        
        // Calculate the notification trigger time
        let notificationMinutes = (task.notifyBeforeHours * 60) + task.notifyBeforeMinutes
        let notificationTime = task.dueTime.addingTimeInterval(-Double(notificationMinutes * 60))
        
        // Only schedule if notification time is in the future
        guard notificationTime > Date() else {
            print("⏰ Notification time is in the past for task: \(task.title)")
            print("   Notification time: \(formatDate(notificationTime)) | Current time: \(formatDate(Date()))")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "'\(task.title)' is due soon"
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        // Add custom data
        content.userInfo = ["taskId": task.id.uuidString]
        
        // Create calendar-based trigger using DateComponents
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification for task \(task.title): \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled for task '\(task.title)'")
                print("   Due time: \(self.formatDate(task.dueTime))")
                print("   Notify at: \(self.formatDate(notificationTime))")
            }
        }
    }
    
    // MARK: - Cancel Notification for Task
    /// Cancels a previously scheduled notification for a task
    /// - Parameter taskId: The UUID of the task to cancel notification for
    func cancelNotification(for taskId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId.uuidString])
        print("❌ Notification cancelled for task: \(taskId.uuidString)")
    }
    
    // MARK: - Reschedule Notification for Task
    /// Cancels existing notification and schedules a new one
    /// Used when task notification settings are updated
    /// - Parameter task: The updated task
    func rescheduleNotification(for task: Task) {
        cancelNotification(for: task.id)
        scheduleNotification(for: task)
    }
    
    // MARK: - Cancel All Notifications
    /// Cancels all pending notifications (useful for app cleanup)
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ All notifications cancelled")
    }
    
    // MARK: - Get Pending Notifications
    /// Retrieves all pending notifications for debugging
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
    
    // MARK: - Helper: Format Date for Debugging
    /// Formats a date for readable debug output
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy h:mm:ss a"
        return formatter.string(from: date)
    }
}
