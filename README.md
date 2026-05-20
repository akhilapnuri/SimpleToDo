# SimpleToDo - One Focus

A minimalist iOS task management app built with SwiftUI that helps you focus on what matters today.

## Core Features & Technical Implementation

### Push Notifications for Task Reminders

Users can set a "Notify Before" on any task using hours and minutes, anywhere from 5 minutes to the full remaining time. The app uses UNCalendarNotificationTrigger with exact date/time components to keep scheduling reliable. A NotificationManager singleton handles everything from scheduling to cancelling notifications, and a UNUserNotificationCenterDelegate makes sure notifications still show up even when the app is already open. Notifications also automatically reschedule whenever the app relaunches.

### Task Persistence & Daily Reset

Tasks are stored as a JSON-encoded array in UserDefaults, which keeps things simple and fully offline. Every time the app opens, it compares the current calendar date to detect a new day. When a new day is detected, tasks and all pending notifications are completely wiped, not just hidden from the UI, so there's no leftover data carrying over. This daily reset is intentional and core to the app's focus-on-today philosophy.

### Task Sorting System

Sort preferences are saved through @AppStorage so they persist across sessions. Users can sort by Date Added, Due Time, or A to Z, in either ascending or descending order. The filteredTasks computed property handles this by first filtering tasks by tab, then applying the chosen sort method, and finally applying direction. Because it's a computed property, any add, edit, or delete action automatically triggers a refresh.

### Task Model with Notification Preferences

Each task carries a UUID, title, description, due time, and completion status, along with fields for notification preferences. The model conforms to Identifiable, Codable, and Equatable. Validation logic prevents users from setting a notification time under 5 minutes before expiration or beyond the remaining time until the task is due, with error messages that guide them toward a valid range.

### Dark/Light Mode Support

Dark mode preference is stored in @AppStorage and applied across every view in the app, including navigation, the progress chart, task cards, and modals. The app checks the isDarkMode flag on all color properties, so toggling the setting takes effect immediately and persists across restarts.

### Progress Chart

The donut chart uses Circle().trim() for its shape and a LinearGradient with layered shadows for a glow effect. It calculates progress in real time based on completed versus total tasks and displays the percentage in the center. The radial glow background is clipped to the circle to avoid a square artifact that showed up in earlier versions.

### Swipe-to-Reveal Actions

Horizontal swipes trigger delete and edit buttons at a -160pt offset, with a snap-to-reveal threshold at -40pt. The gesture detects directional intent by requiring horizontal movement to be more than twice the vertical movement, which prevents accidental triggers while scrolling. A rubber-band effect kicks in during overshoot to make the interaction feel physical. Switching from .simultaneousGesture() to .gesture() was what allowed the ScrollView to handle vertical drags independently without conflict.

### Keyboard Dismissal

Tapping outside a text field dismisses the keyboard using UIApplication.resignFirstResponder() attached to a tap gesture on the background VStack. The tap target is set up to exclude interactive buttons so nothing gets accidentally triggered. This mostly improves the experience inside the AddTask and EditTask modals where the keyboard would otherwise stay up.

### Architecture

The project follows an MVVM structure. Models holds the Task data model, ViewModels holds TaskViewModel which manages state and persistence, Views holds all the SwiftUI views, and Utilities holds NotificationManager and a small IconGenerator helper. Assets are in a standard xcassets folder.