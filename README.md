# SimpleToDo - One Focus

A minimalist iOS task management app built with SwiftUI that helps you focus on what matters today.

## Core Features & Technical Implementation

### 🔔 Push Notifications for Task Reminders
**Tech Stack:** `UserNotifications` framework with `UNUserNotificationCenterDelegate`

**How It Works:**
- Users can set "Notify Before" on any task with hours and minutes (5 min to full remaining time)
- Notifications use **`UNCalendarNotificationTrigger`** with exact date/time components for reliable scheduling
- `NotificationManager` singleton handles all notification lifecycle:
  - `scheduleNotification()` - Schedules based on notify settings
  - `rescheduleNotification()` - Updates when task is edited
  - `cancelNotification()` - Removes when task completes or deletes
- **Foreground handling:** `UNUserNotificationCenterDelegate` displays notifications even when app is open
- **App launch:** Notifications automatically reschedule on app relaunch via `TaskViewModel.loadTasks()`

**Key Logic:**
```
Notification Time = Due Time - (Hours × 60 + Minutes)
Validation: 5 minutes ≤ notify time ≤ full remaining time
```

---

### 💾 Task Persistence & Daily Reset
**Tech Stack:** `UserDefaults` for local storage, `Codable` for JSON encoding/decoding

**How It Works:**
- Tasks stored as JSON-encoded array in `UserDefaults`
- **Daily reset** detected via comparing calendar start-of-day dates
- When new day detected:
  - All tasks cleared from memory AND UserDefaults
  - All pending notifications cancelled
  - Fresh start guaranteed
- **Key difference:** Complete data removal (not just UI clearing) ensures no lingering data

**Why It Matters:**
- Simple, offline-first approach
- No database required
- Data doesn't persist between days (intentional design)

---

### 🔤 Task Sorting System
**Tech Stack:** `@AppStorage` for persistent preferences, computed properties for dynamic filtering

**How It Works:**
- Sort preferences stored in `@AppStorage`:
  - `taskSortBy`: "Date Added" | "Due Time" | "A to Z"
  - `taskSortDirection`: "Ascending" | "Descending"
- `filteredTasks` computed property applies sorting **after** tab filtering:
  1. Filter by tab (My Tasks = incomplete, Completed = completed)
  2. Apply sorting method:
     - **Date Added:** Sort by UUID
     - **Due Time:** Sort by `dueTime` timestamp
     - **A to Z:** Case-insensitive alphabetical
  3. Apply direction (ascending/descending)

**Applies to:** All tabs, all states (add/edit/delete triggers refresh)

---

### ⏰ Task Model with Notification Preferences
**Tech Stack:** `Identifiable`, `Codable`, `Equatable` protocols

**Properties:**
- Core: `id` (UUID), `title`, `description`, `dueTime`, `isCompleted`
- Notifications: `notifyBeforeEnabled`, `notifyBeforeHours`, `notifyBeforeMinutes`

**Validation:**
- Prevents notification time < 5 minutes before expiration
- Prevents notification time > remaining time until expiration
- Error messages guide user to valid ranges

---

### 🎨 Dark/Light Mode Support
**Tech Stack:** `@AppStorage("isDarkMode")` for persistence, conditional color scheme

**How It Works:**
- All color properties check `isDarkMode` flag
- Changes persist across app restarts
- Applied to all views: navigation, progress chart, task cards, modals

---

### 📊 Progress Chart (Donut Visualization)
**Tech Stack:** `Circle().trim()` for donut shape, `LinearGradient` + shadows for glow effect

**Key Features:**
- Real-time progress calculation: `(completedTasks / totalTasks)`
- Animated gradient stroke with multi-layer shadows
- Radial glow background clipped to circle (fixed square artifact)
- Center percentage text with shadow effects

---

### ✏️ Swipe-to-Reveal Actions
**Tech Stack:** `DragGesture` with directional detection, rubber-band physics

**How It Works:**
- Detects horizontal drag > 2x vertical movement (prevents scroll interference)
- Rubber-band effect during overshoot using `translationWidth * rubberBandFactor`
- Reveals delete/edit buttons at `-160pt` offset
- Snap-to-reveal at `-40pt` threshold

**Technical Detail:** Changed from `.simultaneousGesture()` to `.gesture()` to let ScrollView handle vertical drags independently.

---

### ⌨️ Keyboard Dismissal
**Tech Stack:** `UIApplication.resignFirstResponder()` via tap gesture

**How It Works:**
- `onTapGesture` on VStack dismisses keyboard when tapping outside text fields
- Tap target area excludes interactive buttons
- Improves UX in modal forms (AddTaskView, EditTaskView)

---

### 🗂️ Architecture

**Folder Structure:**
```
SimpleToDo/
├── Models/
│   └── Task.swift                  # Task model with notification fields
├── ViewModels/
│   └── TaskViewModel.swift         # MVVM state management + persistence
├── Views/
│   ├── MainAppView.swift          # Main UI with filtering & sorting
│   ├── AddTaskView.swift          # Create task with notifications
│   ├── EditTaskView.swift         # Edit task and preferences
│   ├── TaskBarView.swift          # Individual task card with swipe actions
│   ├── SettingsView.swift         # Dark mode & sort preferences
│   └── LandingView.swift          # Onboarding screen
├── Utilities/
│   ├── NotificationManager.swift  # Notification lifecycle
│   └── IconGenerator.swift        # App icon creation utility
└── Assets.xcassets/               # Images, colors, app icon
```

---

### 🚀 Key Technical Decisions

| Feature | Tech Choice | Why |
|---------|------------|-----|
| Notifications | `UNCalendarNotificationTrigger` | More reliable than time-interval for exact times |
| Storage | `UserDefaults` + `Codable` | Simple, no external dependencies |
| State Management | `@StateObject` + `@Published` | SwiftUI best practice for MVVM |
| Sorting | Computed property | Reactive to `@AppStorage` changes |
| Persistence | `@AppStorage` | Automatic persistence without manual sync |
| Daily Reset | Date comparison | Clean, simple logic for daily boundary |

---

### 📱 User Experience Features

- **Full page scrolling** - Pie chart, tabs, and tasks scroll together
- **Animated transitions** - Spring animations for tab switches and UI changes
- **Real-time validation** - Notification time errors show immediately
- **Visual feedback** - Glow effects, shadows, color changes
- **Accessibility** - High contrast colors, readable fonts, clear affordances

---

**Built with:** SwiftUI, Combine, UserNotifications, Foundation
**Minimum iOS:** iOS 15.0+
**Latest Update:** May 20, 2026
