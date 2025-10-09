# 🗺️ AR Campus Navigation System

> Smart indoor navigation system for university campuses using advanced pathfinding algorithms

[![Dart](https://img.shields.io/badge/Dart-45.2%25-00D9FF?style=flat&logo=dart)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## ✨ Features

### ✅ Currently Implemented
- **Graph-based Pathfinding**: Dijkstra's algorithm for shortest path calculation
- **Multi-floor Navigation**: Support for buildings with multiple floors (2+ floors)
- **Location System**: Comprehensive node-based location mapping with coordinates
- **AR Simulation**: Mock AR interface for route visualization
- **Clean Architecture**: Service layer pattern with separation of concerns
- **NavigationService**: Centralized service with campus map data management
- **Step-by-step Guidance**: Real-time navigation instructions with floor transitions

### 🔮 Upcoming Features
- [ ] A* algorithm implementation with performance comparison
- [ ] Real AR integration using AR Foundation
- [ ] Indoor positioning with Bluetooth beacons
- [ ] Algorithm visualization dashboard
- [ ] Accessibility features (wheelchair routing, voice guidance)
- [ ] ML-based crowd prediction for dynamic routing

## 🛠️ Tech Stack

- **Framework**: Flutter / Dart
- **Algorithms**: Graph Theory (Dijkstra's Algorithm)
- **Architecture**: Layered Architecture with Service Pattern
- **State Management**: StatefulWidget
- **Data Structures**: Priority Queue, Graph (Adjacency List)

## 📱 Screenshots

*Coming soon...*

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Android/iOS emulator or physical device

### Installation
```bash
# Clone the repository
git clone https://github.com/ufukkartaldev-tech/ar-campus-navigation.git

# Navigate to project directory
cd ar-campus-navigation

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📂 Project Structure
```
lib/
├── models/
│   ├── location.dart       # Location data model with coordinates
│   └── graph.dart           # Graph structure & Dijkstra implementation
├── services/
│   └── navigation_service.dart  # Business logic & route calculation
├── screens/
│   ├── home_screen.dart
│   └── ar_navigation_screen.dart
└── main.dart
```

## 🎯 How It Works

1. **Location Selection**: User selects start and destination points from dropdown
2. **Path Calculation**: Dijkstra's algorithm computes the shortest route through campus
3. **Route Visualization**: Display route with distance and step-by-step instructions
4. **AR Navigation**: Mock AR interface shows directions with floor transitions
5. **Step Navigation**: User progresses through route nodes with visual guidance

## 📊 Algorithm Details

### Dijkstra's Algorithm
- **Time Complexity**: O((V + E) log V) where V = vertices, E = edges
- **Space Complexity**: O(V + E)
- **Implementation**: Priority queue-based with adjacency list
- **Guarantees**: Shortest path in weighted, non-negative graphs

### Graph Structure
- **Nodes**: Locations (buildings, classrooms, corridors, stairs)
- **Edges**: Connections with distances in meters
- **Weights**: Physical distance between locations

## 🏗️ Architecture

The project follows a clean layered architecture:

- **Presentation Layer**: Flutter widgets and screens
- **Business Logic Layer**: NavigationService for route calculations
- **Data Layer**: Location and Graph models
- **Utilities**: Graph algorithms and helper functions

## 🎓 Use Cases

- Campus navigation for students and visitors
- Indoor navigation in large buildings
- Multi-floor building wayfinding
- Accessible routing for people with disabilities
- Algorithm demonstration for educational purposes

## 📈 Future Improvements

- Real-time location tracking with GPS/Bluetooth
- User-generated location reviews and ratings
- Integration with campus event schedules
- Offline map support
- Multi-language support

## 🤝 Contributing

This is currently a personal project for portfolio and competition purposes. However, suggestions and feedback are welcome!

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Ufuk Kartal**
- GitHub: [@ufukkartaldev-tech](https://github.com/ufukkartaldev-tech)

- Email: [ufuk.kartal.dev@gmail.com]

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Graph theory and pathfinding algorithm resources
- Campus navigation research papers

---

⭐ **Star this repo if you find it interesting!**

📱 **Built with Flutter** | 🎯 **Powered by Dijkstra's Algorithm**
