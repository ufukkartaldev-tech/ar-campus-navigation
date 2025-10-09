// lib/services/navigation_service.dart

import '../models/location.dart';
import '../models/graph.dart';
import '../models/route_result.dart'; // YENİ: RouteResult modelini ekledik
import 'dart:math' as math;
import 'dart:async'; // Asenkron işlemler için
import 'package:collection/collection.dart'; // firstWhereOrNull için

/// Uygulamanın navigasyon hesaplamalarından ve rota hesaplamasından sorumlu servistir.
class NavigationService {
  late Graph graph;
  late List<Location> _allLocations;

  // YENİ EKLENDİ: Yürüyüş hızı sabiti (metre/saniye)
  static const double AVERAGE_WALKING_SPEED_MPS = 1.4;

  NavigationService() {
    _initializeLocations();
    _createGraph();
  }

  /// Kampüsteki tüm önemli konumları ve düğümleri (node) tanımlar.
  void _initializeLocations() {
    _allLocations = [
      Location(id: 'A101', name: 'Yazılım Lab 1', floor: 1, isBuilding: true, type: 'Classroom', description: 'Bilgisayar laboratuvarı.', x: 400.0, y: 300.0, parentId: 'BINA_A'),
      Location(id: 'A102', name: 'Proje Odası', floor: 1, isBuilding: true, type: 'Room', description: 'Küçük grup odası.', x: 400.0, y: 450.0, parentId: 'BINA_A'),
      Location(id: 'B201', name: 'Öğretim Üyesi Ofisi', floor: 2, isBuilding: true, type: 'Office', description: 'Prof. Ofisi.', x: 450.0, y: 350.0, parentId: 'BINA_B'),
      Location(id: 'B202', name: 'Sınıf B-202', floor: 2, isBuilding: true, type: 'Classroom', description: 'Genel amaçlı derslik.', x: 550.0, y: 450.0, parentId: 'BINA_B'),
      Location(id: 'YEMEKHANE', name: 'Merkez Yemekhane', floor: 1, isBuilding: true, type: 'Facility', description: 'Merkez yemekhane.', x: 350.0, y: 50.0, parentId: 'BINA_Y'),
      Location(id: 'GIRIS', name: 'Ana Giriş', floor: 1, isBuilding: true, type: 'Entrance', description: 'Bina ana girişi.', x: 100.0, y: 50.0, parentId: 'BINA_A'),
      Location(id: 'BINA_A', name: 'A Blok', floor: 1, isBuilding: true, type: 'building', description: 'A Blok.', x: 0.0, y: 0.0),
      Location(id: 'BINA_B', name: 'B Blok', floor: 2, isBuilding: true, type: 'building', description: 'B Blok.', x: 0.0, y: 0.0),
      Location(id: 'BINA_Y', name: 'Yemekhane Bloğu', floor: 1, isBuilding: true, type: 'building', description: 'Merkez Yemekhane.', x: 0.0, y: 0.0),
      Location(id: 'N1', name: 'Koridor A Ortası', floor: 1, isBuilding: false, type: 'NavNode', description: 'Koridor geçiş noktası.', x: 200.0, y: 200.0),
      Location(id: 'N2', name: 'Koridor A Sonu', floor: 1, isBuilding: false, type: 'NavNode', description: 'Koridor A sonu.', x: 500.0, y: 200.0),
      Location(id: 'N3', name: 'Koridor B Ortası', floor: 2, isBuilding: false, type: 'NavNode', description: 'Koridor B ortası.', x: 500.0, y: 250.0),
      Location(id: 'S1', name: 'Merdiven A (1. Kat)', floor: 1, isBuilding: false, type: 'Stairs', description: 'Merdiven A başlangıç.', x: 50.0, y: 200.0),
      Location(id: 'S1_UST', name: 'Merdiven A (2. Kat)', floor: 2, isBuilding: false, type: 'Stairs', description: 'Merdiven A çıkış.', x: 50.0, y: 200.0),
    ];
  }

  List<Location> getAllLocations() => _allLocations;

  Location getLocationById(String id) {
    return _allLocations.firstWhere(
          (loc) => loc.id == id,
      orElse: () => throw Exception('Location ID "$id" bulunamadı.'),
    );
  }

  double getPhysicalDistanceBetween(String fromId, String toId) {
    final from = getLocationById(fromId);
    final to = getLocationById(toId);

    double dx = to.x - from.x;
    double dy = to.y - from.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double _calculateDistance(String fromId, String toId) {
    final from = getLocationById(fromId);
    final to = getLocationById(toId);

    double dx = to.x - from.x;
    double dy = to.y - from.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  void _createGraph() {
    graph = Graph();

    for (var loc in _allLocations) {
      graph.addNode(loc.id);
    }

    _addBidirectionalEdge('GIRIS', 'N1');
    _addBidirectionalEdge('N1', 'A101');
    _addBidirectionalEdge('N1', 'A102');
    _addBidirectionalEdge('A102', 'YEMEKHANE');
    _addBidirectionalEdge('N1', 'S1');
    _addBidirectionalEdge('N1', 'N2');

    _addBidirectionalEdge('S1', 'S1_UST', costMultiplier: 2.0);

    _addBidirectionalEdge('S1_UST', 'N3');
    _addBidirectionalEdge('N3', 'B201');
    _addBidirectionalEdge('N3', 'B202');
  }

  void _addBidirectionalEdge(String id1, String id2, {double costMultiplier = 1.0}) {
    final physicalDistance = _calculateDistance(id1, id2);
    final costDistance = physicalDistance * costMultiplier;

    graph.addEdge(id1, id2, costDistance, physicalDistance: physicalDistance);
    graph.addEdge(id2, id1, costDistance, physicalDistance: physicalDistance);
  }

  Future<RouteResult> findShortestPath(String startId, String endId) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final start = getLocationById(startId);
    final end = getLocationById(endId);

    final distances = <String, double>{};
    final previousNodes = <String, String?>{};
    final unvisited = <String>{};

    for (var nodeId in graph.adjacencyList.keys) {
      distances[nodeId] = double.infinity;
      previousNodes[nodeId] = null;
      unvisited.add(nodeId);
    }

    distances[start.id] = 0;

    while (unvisited.isNotEmpty) {
      String? currentNodeId;
      double minDistance = double.infinity;

      for (var nodeId in unvisited) {
        if (distances[nodeId]! < minDistance) {
          minDistance = distances[nodeId]!;
          currentNodeId = nodeId;
        }
      }

      if (currentNodeId == null) break;
      if (currentNodeId == end.id) break;

      unvisited.remove(currentNodeId);

      for (var edge in graph.adjacencyList[currentNodeId]!) {
        final neighborId = edge.toId;
        if (unvisited.contains(neighborId)) {
          final newDistance = distances[currentNodeId]! + edge.cost;
          if (newDistance < distances[neighborId]!) {
            distances[neighborId] = newDistance;
            previousNodes[neighborId] = currentNodeId;
          }
        }
      }
    }

    final path = <String>[];
    String? current = end.id;

    while (current != null) {
      path.add(current);
      if (current == start.id) break;
      current = previousNodes[current];
    }

    final routeNodeIds = path.reversed.toList();

    if (routeNodeIds.isEmpty || routeNodeIds.first != startId || routeNodeIds.last != endId) {
      throw Exception('Rota bulunamadı. Lütfen farklı bir başlangıç ve hedef seçin.');
    }

    final totalDistance = _calculateTotalDistance(routeNodeIds);
    final instructions = _convertRouteToInstructions(routeNodeIds);

    return RouteResult(
      routeNodeIds: routeNodeIds,
      totalDistance: totalDistance,
      instructions: instructions,
    );
  }

  /// Null-safe ve güvenli total distance hesaplama
  double _calculateTotalDistance(List<String> routeNodeIds) {
    double totalDistance = 0.0;
    if (routeNodeIds.length < 2) return 0.0;

    for (int i = 0; i < routeNodeIds.length - 1; i++) {
      final fromId = routeNodeIds[i];
      final toId = routeNodeIds[i + 1];

      final edge = graph.adjacencyList[fromId]?.firstWhereOrNull(
            (e) => e.toId == toId,
      );

      if (edge != null) {
        totalDistance += edge.physicalDistance;
      } else {
        throw Exception('Edge bulunamadı: $fromId -> $toId');
      }
    }

    return double.parse(totalDistance.toStringAsFixed(1));
  }

  String _convertRouteToInstructions(List<String> routeNodeIds) {
    final instructions = StringBuffer('');

    if (routeNodeIds.isEmpty) return 'Rota bulunamadı.';

    for (int i = 0; i < routeNodeIds.length; i++) {
      final location = getLocationById(routeNodeIds[i]);

      if (i == 0) {
        instructions.writeln('🚩 BAŞLANGIÇ: ${location.name} (${location.floor}. Kat)');
      } else if (i == routeNodeIds.length - 1) {
        instructions.writeln('🎯 HEDEF: ${location.name} (${location.floor}. Kat)');
      } else {
        final nextLocation = getLocationById(routeNodeIds[i+1]);

        if (location.floor != nextLocation.floor) {
          if (nextLocation.floor > location.floor) {
            instructions.writeln('${i+1}. 📈 ${location.name} → ${nextLocation.floor}. kata ÇIKIN');
          } else {
            instructions.writeln('${i+1}. 📉 ${location.name} → ${nextLocation.floor}. kata İNİN');
          }
        } else if (location.type == 'Stairs' || location.type == 'NavNode') {
          instructions.writeln('${i+1}. ➡️ ${location.name} üzerinden ilerleyin');
        } else if (location.isBuilding) {
          instructions.writeln('${i+1}. 🏛️ ${location.name} yakınından geçin');
        }
      }
    }

    return instructions.toString();
  }
}
