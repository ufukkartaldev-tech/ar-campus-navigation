// Dijkstra Algoritmasını içeren temel Graph yapısı
import 'dart:collection';

class Graph {
  // Tüm düğümlerin kenarlarını tutar: { 'A': { 'B': 10.0, 'C': 5.0 } }
  final Map<String, Map<String, double>> edges = {};

  // Kenar ekleme metodu
  void addEdge(String from, String to, double distance) {
    // Çift yönlü kenar ekleme (Gidip gelme mesafesi aynıdır)
    edges.putIfAbsent(from, () => {});
    edges[from]![to] = distance;

    edges.putIfAbsent(to, () => {});
    edges[to]![from] = distance;
  }

  // Dijkstra algoritması ile en kısa yolu bulur
  List<String> shortestPath(String startId, String endId) {
    // Mesafeleri tutar: { 'A': 0.0, 'B': sonsuz, ... }
    final distances = <String, double>{};
    // Önceki düğümü tutar: { 'B': 'A' }
    final previousNodes = <String, String?>{};
    // İşlenmemiş düğümler (Öncelikli kuyruk gibi)
    final priorityQueue = PriorityQueue<String>();

    // Başlangıç değerlerini ata
    for (var node in edges.keys) {
      if (node == startId) {
        distances[node] = 0.0;
      } else {
        distances[node] = double.infinity;
      }
      previousNodes[node] = null;
      priorityQueue.add(node, distances[node]!);
    }

    while (priorityQueue.isNotEmpty) {
      String? current = priorityQueue.removeMin();

      if (current == null) continue;

      // Hedefe ulaşıldıysa döngüyü kır
      if (current == endId) break;

      // Komşularını işle
      edges[current]?.forEach((neighbor, distance) {
        final newDistance = distances[current]! + distance;

        if (newDistance < distances[neighbor]!) {
          distances[neighbor] = newDistance;
          previousNodes[neighbor] = current;
          priorityQueue.add(neighbor, newDistance); // Kuyruğu güncelle
        }
      });
    }

    // Rota oluşturma
    List<String> route = [];
    String? current = endId;

    while (current != null && previousNodes.containsKey(current)) {
      route.add(current);
      current = previousNodes[current];
      if (current == startId) {
        route.add(startId);
        break;
      }
    }

    return route.reversed.toList();
  }

  // Rota üzerindeki toplam mesafeyi hesaplar
  double calculateTotalDistance(List<String> route) {
    if (route.length < 2) return 0.0;
    double totalDistance = 0.0;

    for (int i = 0; i < route.length - 1; i++) {
      String from = route[i];
      String to = route[i + 1];

      // Kenar ağırlığını kontrol et
      if (edges.containsKey(from) && edges[from]!.containsKey(to)) {
        totalDistance += edges[from]![to]!;
      } else {
        // Hata durumunda (aslında olmamalı)
        print('Hata: Kenar bulunamadı $from -> $to');
        return double.infinity;
      }
    }

    return totalDistance;
  }

  // Debug için graph'ı yazdırır
  void printGraph() {
    print("--- Graph Yapısı ---");
    edges.forEach((key, value) {
      print('$key -> $value');
    });
    print("--------------------");
  }
}

// Dijkstra için basit Öncelikli Kuyruk uygulaması
class PriorityQueue<E> {
  final Map<E, double> _elements = {};

  bool get isNotEmpty => _elements.isNotEmpty;

  // Düğümü mesafesiyle birlikte ekle/güncelle
  void add(E element, double priority) {
    _elements[element] = priority;
  }

  // En düşük mesafeye sahip düğümü bul ve çıkar
  E? removeMin() {
    if (_elements.isEmpty) return null;

    E? minElement;
    double minPriority = double.infinity;

    _elements.forEach((element, priority) {
      if (priority < minPriority) {
        minPriority = priority;
        minElement = element;
      }
    });

    if (minElement != null) {
      _elements.remove(minElement);
    }
    return minElement;
  }
}
