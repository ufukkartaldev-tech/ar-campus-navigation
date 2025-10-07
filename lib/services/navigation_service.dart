import '../models/location.dart';
import '../models/graph.dart';
import 'dart:math';

class NavigationService {
  // Tüm lokasyonları (Location ID'sine göre) hafızada tutmak için Map
  // NavigationService bir kere başlatıldığında veriyi hazırlar.
  late final Map<String, Location> _locationMap;
  late final Graph _graph; // Graph'ı da bir kere oluşturup tutuyoruz.

  NavigationService() {
    // 1. Lokasyonları yükle
    _locationMap = {for (var loc in _initialLocations) loc.id: loc};
    // 2. Graph'ı oluştur
    _graph = _createTestGraph();
  }

  // YÜKLEME LİSTESİ: Koordinatları ve Ara Düğümleri (Koridor/Merdiven) içerir.
  List<Location> get _initialLocations => [
    // BİNALAR (Koordinatlar X: Kampüs bazlı, Y: Kampüs bazlı)
    Location(id: 'muhendislik', name: 'Mühendislik Fakültesi', type: 'building', description: 'Mühendislik Fakültesi', floor: 0, isBuilding: true, x: 100.0, y: 50.0),
    Location(id: 'fen_edebiyat', name: 'Fen Edebiyat Fakültesi', type: 'building', description: 'Fen Edebiyat Fakültesi', floor: 0, isBuilding: true, x: 250.0, y: 120.0),
    Location(id: 'kutuphane', name: 'Kütüphane', type: 'library', description: 'Merkez Kütüphane', floor: 0, isBuilding: true, x: 350.0, y: 100.0),
    Location(id: 'kantin', name: 'Kantin', type: 'cafeteria', description: 'Ana Kantin', floor: 0, isBuilding: true, x: 10.0, y: 10.0),
    Location(id: 'kafeterya', name: 'Kafeterya', type: 'cafeteria', description: 'Öğrenci Kafeteryası', floor: 0, isBuilding: true, x: 20.0, y: 5.0),

    // MÜHENDİSLİK İÇİ ARA DÜĞÜMLER (Lokal Koordinatlar: X: koridor boyunca, Y: koridorun eni)
    Location(id: 'merdiven_2kat', name: '2. Kat Merdiven', parentId: 'muhendislik', type: 'stairs', description: 'Mühendislik Merdiven Başlangıcı', floor: 1, x: 2.0, y: 5.0),
    Location(id: 'koridor_giris', name: 'Koridor Giriş', parentId: 'muhendislik', type: 'corridor', description: '2. Kat Koridor Girişi', floor: 2, x: 5.0, y: 10.0),
    Location(id: 'koridor_orta', name: 'Koridor Orta', parentId: 'muhendislik', type: 'corridor', description: '2. Kat Koridor Ortası', floor: 2, x: 15.0, y: 10.0),
    Location(id: 'koridor_sonu', name: 'Koridor Sonu', parentId: 'muhendislik', type: 'corridor', description: '2. Kat Koridor Sonu', floor: 2, x: 23.0, y: 10.0),

    // MÜHENDİSLİK SINIFLARI ve LAB'lar (Koordinatlar)
    Location(id: 'd201', name: 'D201 Sınıfı', parentId: 'muhendislik', type: 'classroom', description: 'D201 Sınıfı', floor: 2, x: 6.0, y: 12.0),
    Location(id: 'd202', name: 'D202 Sınıfı', parentId: 'muhendislik', type: 'classroom', description: 'D202 Sınıfı', floor: 2, x: 7.0, y: 8.0),
    Location(id: 'd203', name: 'D203 Sınıfı', parentId: 'muhendislik', type: 'classroom', description: 'D203 Sınıfı', floor: 2, x: 16.0, y: 12.0),
    Location(id: 'lab_bilisim', name: 'Bilişim Laboratuvarı', parentId: 'muhendislik', type: 'lab', description: 'Bilişim Lab', floor: 2, x: 12.0, y: 12.0),
    Location(id: 'lab_elektrik', name: 'Elektrik Laboratuvarı', parentId: 'muhendislik', type: 'lab', description: 'Elektrik Lab', floor: 2, x: 18.0, y: 12.0),

    // FEN EDEBİYAT SINIFLARI (Mock olarak)
    Location(id: 'fen_merdiven', name: 'Fen Edebiyat Merdiven', parentId: 'fen_edebiyat', type: 'stairs', description: 'Fen Merdiven', floor: 1, x: 2.0, y: 8.0),
    Location(id: 'fen_koridor', name: 'Fen Koridor', parentId: 'fen_edebiyat', type: 'corridor', description: 'Fen Koridor', floor: 1, x: 10.0, y: 8.0),
    Location(id: 'a101', name: 'A101 Sınıfı', parentId: 'fen_edebiyat', type: 'classroom', description: 'A101 Sınıfı', floor: 1, x: 10.0, y: 1.0),
    Location(id: 'a102', name: 'A102 Sınıfı', parentId: 'fen_edebiyat', type: 'classroom', description: 'A102 Sınıfı', floor: 1, x: 10.0, y: 2.0),

    // KÜTÜPHANE ALANLARI (Mock olarak)
    Location(id: 'kutuphane_giris', name: 'Kütüphane Giriş', parentId: 'kutuphane', type: 'corridor', description: 'Kütüphane Giriş', floor: 0, x: 10.0, y: 1.0),
    Location(id: 'kutuphane_okuma', name: 'Okuma Salonu', parentId: 'kutuphane', type: 'library', description: 'Okuma Salonu', floor: 1, x: 15.0, y: 1.0),
    Location(id: 'kutuphane_bilgisayar', name: 'Bilgisayar Laboratuvarı', parentId: 'kutuphane', type: 'library', description: 'Bilgisayar Lab', floor: 2, x: 15.0, y: 2.0),

  ];

  // Sadece ID'ye göre bir Location objesi döndüren metot
  Location getLocationById(String id) {
    if (!_locationMap.containsKey(id)) {
      throw Exception('Lokasyon ID bulunamadı: $id');
    }
    return _locationMap[id]!;
  }

  // Tüm lokasyonları getir
  List<Location> getAllLocations() {
    return _locationMap.values.toList();
  }

  // Seçili binadaki sınıfları getir
  List<Location> getClassrooms(String buildingId) {
    return _locationMap.values.where((loc) => loc.parentId == buildingId && loc.type == 'classroom').toList();
  }

  // TEST GRAPH'INI OLUŞTUR
  Graph _createTestGraph() {
    Graph graph = Graph();

    // MÜHENDİSLİK FAKÜLTESİ (2. KAT ODAKLANMASI)

    // Merdiven Bağlantıları (Katlar arası geçişler, genellikle binalar arası mesafeden daha kısadır)
    // NOT: Merdivenler genelde 1. kat ile 2. kat arasını bağlar
    graph.addEdge('merdiven_2kat', 'koridor_giris', 5.0);

    // Koridor Bağlantıları
    graph.addEdge('koridor_giris', 'koridor_orta', 10.0); // 10 metre
    graph.addEdge('koridor_orta', 'koridor_sonu', 8.0); // 8 metre

    // Koridor -> Sınıf/Lab Bağlantıları (Kapıdan koridora mesafe)
    graph.addEdge('koridor_giris', 'd201', 3.0);
    graph.addEdge('koridor_giris', 'd202', 5.0);
    graph.addEdge('koridor_orta', 'lab_bilisim', 4.0);
    graph.addEdge('koridor_sonu', 'lab_elektrik', 3.0);

    // MÜHENDİSLİK - FEN EDEBİYAT ARASI (Binalar arası geçiş)
    // Bu mesafeler mock, harita izni alınınca güncellenecek.
    graph.addEdge('muhendislik', 'fen_edebiyat', 50.0);
    graph.addEdge('muhendislik', 'kutuphane', 70.0);
    graph.addEdge('fen_edebiyat', 'kutuphane', 30.0);

    // BİNADAN KORİDORA BAĞLANTI (Çok önemli, bu binanın girişidir!)
    // Mühendislik binası girisinden merdivene olan mesafe
    graph.addEdge('muhendislik', 'merdiven_2kat', 15.0);
    // Fen Edebiyat binası girisinden fen merdivenine olan mesafe
    graph.addEdge('fen_edebiyat', 'fen_merdiven', 12.0);

    // FEN EDEBİYAT KORİDOR BAĞLANTILARI
    graph.addEdge('fen_merdiven', 'fen_koridor', 5.0);
    graph.addEdge('fen_koridor', 'a101', 3.0);
    graph.addEdge('fen_koridor', 'a102', 4.0);

    // KÜTÜPHANE İÇİ
    graph.addEdge('kutuphane_giris', 'kutuphane_okuma', 8.0);
    graph.addEdge('kutuphane_giris', 'kutuphane_bilgisayar', 15.0);
    graph.addEdge('kutuphane', 'kutuphane_giris', 5.0); // Bina girisi -> iç alan

    return graph;
  }

  // Dijkstra ile rota hesapla
  List<String> calculateRouteWithDijkstra(String startId, String endId) {
    try {
      // _graph objesi Constructor'da bir kere oluşturuldu
      List<String> route = _graph.shortestPath(startId, endId);
      return route;
    } catch (e) {
      print('Dijkstra hatası: $e');
      return [];
    }
  }

  // Rota bilgisini insan diline çevir
  String convertRouteToInstructions(List<String> route) {
    if (route.isEmpty) return '❌ Rota bulunamadı!';

    double totalDistance = _graph.calculateTotalDistance(route);
    List<String> instructions = [];

    for (int i = 0; i < route.length - 1; i++) {
      String fromId = route[i];
      String toId = route[i + 1];

      // Her ID'nin Location objesini al
      final fromLocation = getLocationById(fromId);
      final toLocation = getLocationById(toId);

      // Mesafeyi al
      double distance = _graph.edges[fromId]![toId]!;

      String instruction = '';

      // Yönlendirme mantığı (Kat ve tip kontrolü)
      if (toLocation.type == 'stairs') {
        instruction = '⬆️ Merdivenlere Yönel (${distance.toStringAsFixed(1)}m)';
      } else if (toLocation.floor != fromLocation.floor) {
        // Kat değiştirme (merdivenden sonraki adım)
        instruction = '🪜 ${toLocation.floor}. Kata ${toLocation.floor > fromLocation.floor ? "ÇIK" : "İN"}';
      } else if (toLocation.isBuilding) {
        // Bina değiştirme
        instruction = '🚌 Kampüs içinde ${toLocation.name} Binasına Yönel (${distance.toStringAsFixed(1)}m)';
      } else {
        // Koridor/Sınıf içi yönlendirme
        instruction = '➡️ ${distance.toStringAsFixed(1)} metre ilerle ve ${toLocation.name} konumuna ulaş.';
      }

      instructions.add(instruction);
    }

    // Son adımı ekle: Hedefe ulaşıldı
    instructions.add('🎯 Hedefinize ulaştınız: ${getLocationById(route.last).name}');

    return '🗺️ **Navigasyon Rotası**\n\n'
        '📏 Toplam Mesafe: ${totalDistance.toStringAsFixed(1)} metre\n\n'
        '📍 **Rota Detayları:**\n' +
        instructions.join('\n\n') +
        '\n\n✅ **Dijkstra algoritması ile en kısa yol hesaplandı!**';
  }

  // Bu metot artık kullanılmıyor, ancak tutarlılık için eklenmiş. Kaldırılabilir.
  List<String> calculateRoute(Location start, Location end) {
    // Gerçek Dijkstra metodu (calculateRouteWithDijkstra) artık kullanılıyor.
    return [];
  }
}
