# SF Calendar Task - Premium Pastel Calendar

A high-fidelity, premium Flutter calendar application built with a modern "Pastel Dream" aesthetic. This app integrates with the device's native calendar, provides smart event categorization, and supports seamless navigation with a focus on a minimal and professional UI.

## ✨ Features

- **🎨 Premium Pastel UI**: A curated 5-color pastel palette for event categorization and a clean, "zero grid line" calendar interface.
- **🌗 System Dark Mode**: A sophisticated "Midnight Pastel" dark mode that automatically follows system preferences.
- **🔄 Auto-Fetch on Swipe**: The calendar automatically detects month changes during swiping and fetches relevant events in real-time.
- **📅 Smart Navigation**: A compact App Bar with a "Jump to Date" feature and a "Today" button for instant navigation.
- **🏷️ Intelligent Event Mapping**: Automatically assigns icons and pastel colors based on event titles (e.g., "Gym" -> Green/Weights Icon, "Birthday" -> Pink/Cake Icon).
- **🏗️ MVC Architecture**: Organized using Model-View-Controller principles for high maintainability and scalability.
- **🚀 Provider State Management**: Efficient and reactive state management using the Provider package.

## 📸 Screenshots

<p align="center">
  <img src="file:///Users/shihab/.gemini/antigravity/brain/252b08e6-5ff1-4db0-b1b3-cb19269d83a8/media__1775907952308.png" width="30%" alt="Main Calendar View" />
  <img src="file:///Users/shihab/.gemini/antigravity/brain/252b08e6-5ff1-4db0-b1b3-cb19269d83a8/media__1775907952271.png" width="30%" alt="Date Picker Dialog" />
  <img src="file:///Users/shihab/.gemini/antigravity/brain/252b08e6-5ff1-4db0-b1b3-cb19269d83a8/media__1775907952301.png" width="30%" alt="Empty State" />
</p>

## 📂 Project Structure

The project follows a modular **MVC (Model-View-Controller)** folder structure:

```text
lib/
├── models/             # Data models and business logic entities
│   └── calendar_event.dart
├── controllers/        # Provider-based state management logic
│   └── calendar_provider.dart
├── repositories/       # Data fetching and API/Device Calendar logic
│   └── calendar_repository.dart
├── views/              # UI screens and layouts
│   ├── calendar_page.dart
│   └── widgets/        # Reusable widget components
│       └── calendar_data_source.dart
└── main.dart           # App entry point and global theme configuration
```

## 📦 Key Packages

This project leverages industry-standard packages to provide a robust experience:

- **[sf_calendar](https://pub.dev/packages/syncfusion_flutter_calendar)**: Powerful month and agenda view management.
- **[device_calendar](https://pub.dev/packages/device_calendar)**: Seamless integration with system calendar events.
- **[provider](https://pub.dev/packages/provider)**: High-performance state management.
- **[google_fonts](https://pub.dev/packages/google_fonts)**: Modern typography (Outfit) for a premium feel.
- **[intl](https://pub.dev/packages/intl)** & **[timezone](https://pub.dev/packages/timezone)**: Robust date formatting and time zone handling.

## 🛠️ Getting Started

1. **Clone the repository**:
   ```bash
   git clone <repository_url>
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the project**:
   ```bash
   flutter run
   ```

> [!NOTE]
> Ensure you grant **Calendar Permissions** when prompted to see your native device events inside the app.
