# 🚀 Beginner's Guide: Food Delivery App

Welcome! This guide will help you understand how this app is built and where to find things.

## 📂 Project Structure

- **`lib/main.dart`**: The entry point of the app. It sets up the "Providers" (state management) and starts the first screen.
- **`lib/presentation/`**: This folder contains everything you see on the screen (UI).
    - **`screens/`**: Full pages like the Home Screen, Profile, etc.
    - **`widgets/`**: Smaller, reusable pieces like a "Food Card".
- **`lib/providers/`**: This is where the "brain" of the app lives. It manages data (like your shopping cart or the menu) and updates the UI.
- **`lib/data/`**: Handles the raw data.
    - **`models/`**: Defines what a "Food" or "User" looks like in code.
    - **`services/`**: Code that talks to the backend server.

## 🧠 Key Concepts

### 1. Provider (State Management)
We use the `Provider` package to manage data. 
- If you see `notifyListeners()`, it means the data changed, and the UI should update automatically.
- Look at `lib/providers/food_provider.dart` for a good example.

### 2. Consumer & context.read
- **`Consumer`**: Used to listen for changes. If the data in a provider changes, the widget inside a `Consumer` will rebuild.
- **`context.read<...>():`**: Used to trigger an action (like `fetchFoods()`) without needing to rebuild the whole UI.

### 3. Backend Connection
The app talks to a Node.js server. 
- The connection logic is in `lib/data/services/api_service.dart`.
- The backend server must be running for the app to show real food data.

## 🛠️ How to Add a New Feature
1. **Model**: Define the data in `lib/data/models/`.
2. **Provider**: Create a new class in `lib/providers/` to manage that data.
3. **Register**: Add your new provider to the list in `lib/main.dart`.
4. **UI**: Create a new screen in `lib/presentation/screens/` and use `Consumer` to show the data.

Happy Coding! 🇸🇴✨
