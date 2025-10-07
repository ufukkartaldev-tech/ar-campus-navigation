import 'package:flutter/material.dart';
import '../models/location.dart';
import '../services/navigation_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NavigationService _navigationService = NavigationService();

  // BAŞLANGIÇ İÇİN
  Location? selectedStartBuilding;
  Location? selectedStartClassroom;

  // HEDEF İÇİN
  Location? selectedEndBuilding;
  Location? selectedEndClassroom;

  List<Location> locations = [];

  @override
  void initState() {
    super.initState();
    locations = _navigationService.getAllLocations();
  }

  // Binaları getir
  List<Location> get buildings {
    return locations.where((loc) => loc.isBuilding).toList();
  }

  // Seçili binadaki sınıfları getir
  List<Location> getClassrooms(String? buildingId) {
    if (buildingId == null) return [];
    return locations.where((loc) => loc.parentId == buildingId).toList();
  }

  String _getLocationIcon(String type) {
    switch (type) {
      case 'building':
        return '🏛️';
      case 'classroom':
        return '🚪';
      case 'cafeteria':
        return '🍕';
      case 'library':
        return '📚';
      default:
        return '📍';
    }
  }

  // Lokasyonları graph node'larına çevir
  String _convertLocationToNodeId(Location location) {
    // Basit eşleme - sınıf isimlerine göre
    if (location.name.contains('D101')) return 'd201';
    if (location.name.contains('D102')) return 'd202';
    if (location.name.contains('A101')) return 'd203';
    if (location.name.contains('A102')) return 'd204';
    if (location.name.contains('Okuma Salonu')) return 'd205';
    if (location.name.contains('Bilgisayar Laboratuvarı')) return 'd206';
    if (location.name.contains('Kantin')) return 'koridor_giris';
    if (location.name.contains('Kafeterya')) return 'koridor_orta';

    // Binalar için varsayılan node'lar
    if (location.name.contains('Mühendislik')) return 'merdiven_2kat';
    if (location.name.contains('Fen Edebiyat')) return 'koridor_giris';
    if (location.name.contains('Kütüphane')) return 'koridor_sonu';

    return 'koridor_giris'; // Varsayılan
  }

  void _handleNavigation() {
    // Başlangıç ve hedef kontrolü
    final start = selectedStartClassroom ?? selectedStartBuilding;
    final end = selectedEndClassroom ?? selectedEndBuilding;

    if (start == null || end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lütfen başlangıç ve hedef noktalarını seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (start.id == end.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎯 Zaten ${start.name} konumundasınız!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // DİJKSTRA İLE ROTA HESAPLA!
    try {
      // Lokasyon ID'lerini graph node ID'lerine çevir
      String startNodeId = _convertLocationToNodeId(start);
      String endNodeId = _convertLocationToNodeId(end);

      // NavigationService'ten Dijkstra'yı çağır
      List<String> route = _navigationService.calculateRouteWithDijkstra(startNodeId, endNodeId);
      String instructions = _navigationService.convertRouteToInstructions(route);

      if (route.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${start.name} → ${end.name} arasında rota bulunamadı!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Sonucu göster - daha güzel bir dialog ile
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('🗺️ Navigasyon Rotası'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('📍 ${start.name} → 🎯 ${end.name}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                Text(instructions, style: TextStyle(fontSize: 14)),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('✅ Dijkstra algoritması ile en kısa yol hesaplandı!',
                      style: TextStyle(color: Colors.green[800])),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Kapat'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Buraya sonra AR ekranına yönlendirme ekleyeceğiz
                // Navigator.push(context, MaterialPageRoute(
                //   builder: (context) => ARNavigationScreen(start: start, end: end)
                // ));
              },
              child: Text('AR ile Başlat 🚀'),
            ),
          ],
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Rota hesaplanırken hata: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kampüs Navigasyon 🚀'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            // BAŞLIK
            Text(
              'AR Kampüs Navigasyon',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Önce bina, sonra sınıf seçin',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 30),

            // BAŞLANGIÇ BÖLÜMÜ
            Text(
              'BAŞLANGIÇ NOKTASI',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700]),
            ),
            SizedBox(height: 15),

            // BAŞLANGIÇ - BİNA SEÇİMİ
            DropdownButtonFormField<Location>(
              value: selectedStartBuilding,
              decoration: InputDecoration(
                labelText: 'Bina Seçin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: buildings.map((Location building) {
                return DropdownMenuItem<Location>(
                  value: building,
                  child: Text('${_getLocationIcon(building.type)} ${building.name}'),
                );
              }).toList(),
              onChanged: (Location? newBuilding) {
                setState(() {
                  selectedStartBuilding = newBuilding;
                  selectedStartClassroom = null; // Bina değişince sınıfı sıfırla
                });
              },
            ),

            // BAŞLANGIÇ - SINIF SEÇİMİ (sadece bina seçilince göster)
            if (selectedStartBuilding != null) ...[
              SizedBox(height: 15),
              DropdownButtonFormField<Location>(
                value: selectedStartClassroom,
                decoration: InputDecoration(
                  labelText: 'Sınıf Seçin',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.door_front_door),
                ),
                items: getClassrooms(selectedStartBuilding!.id).map((Location classroom) {
                  return DropdownMenuItem<Location>(
                    value: classroom,
                    child: Text('${_getLocationIcon(classroom.type)} ${classroom.name}'),
                  );
                }).toList(),
                onChanged: (Location? newClassroom) {
                  setState(() {
                    selectedStartClassroom = newClassroom;
                  });
                },
              ),
            ],

            SizedBox(height: 30),

            // HEDEF BÖLÜMÜ
            Text(
              'HEDEF NOKTASI',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
            SizedBox(height: 15),

            // HEDEF - BİNA SEÇİMİ
            DropdownButtonFormField<Location>(
              value: selectedEndBuilding,
              decoration: InputDecoration(
                labelText: 'Bina Seçin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: buildings.map((Location building) {
                return DropdownMenuItem<Location>(
                  value: building,
                  child: Text('${_getLocationIcon(building.type)} ${building.name}'),
                );
              }).toList(),
              onChanged: (Location? newBuilding) {
                setState(() {
                  selectedEndBuilding = newBuilding;
                  selectedEndClassroom = null; // Bina değişince sınıfı sıfırla
                });
              },
            ),

            // HEDEF - SINIF SEÇİMİ (sadece bina seçilince göster)
            if (selectedEndBuilding != null) ...[
              SizedBox(height: 15),
              DropdownButtonFormField<Location>(
                value: selectedEndClassroom,
                decoration: InputDecoration(
                  labelText: 'Sınıf Seçin',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.door_front_door),
                ),
                items: getClassrooms(selectedEndBuilding!.id).map((Location classroom) {
                  return DropdownMenuItem<Location>(
                    value: classroom,
                    child: Text('${_getLocationIcon(classroom.type)} ${classroom.name}'),
                  );
                }).toList(),
                onChanged: (Location? newClassroom) {
                  setState(() {
                    selectedEndClassroom = newClassroom;
                  });
                },
              ),
            ],

            SizedBox(height: 40),

            // BUTON
            ElevatedButton(
              onPressed: _handleNavigation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'Yol Tarifi Al 🎯',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            // BİLGİ
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue[700], size: 30),
                  SizedBox(height: 8),
                  Text(
                    'Dijkstra Algoritması Aktif!',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'En kısa yol otomatik hesaplanıyor',
                    style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}