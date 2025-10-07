import 'package:flutter/material.dart';
import '../models/location.dart';
import '../services/navigation_service.dart';

class ARNavigationScreen extends StatefulWidget {
  final Location startLocation;
  final Location endLocation;
  final List<String> routeNodeIds; // Dijkstra'dan gelen ID listesi

  ARNavigationScreen({
    required this.startLocation,
    required this.endLocation,
    required this.routeNodeIds,
  });

  @override
  _ARNavigationScreenState createState() => _ARNavigationScreenState();
}

class _ARNavigationScreenState extends State<ARNavigationScreen> {
  final NavigationService _navigationService = NavigationService();

  // Rota üzerindeki tüm Location objelerini tutacak liste
  List<Location> fullRouteLocations = [];
  int currentStepIndex = 0; // Hangi adımda olduğumuzu takip eder

  // Yeni Durum Değişkenleri: Yükleme durumunu ve hatayı tutarız.
  bool _isLoading = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _loadRouteLocations();
  }

  // Dijkstra ID'lerinden Location objelerini çek
  void _loadRouteLocations() {
    // Artık hata durumunda ekranı direkt kapatmak yerine, hatayı ekranda göstereceğiz.
    try {
      if (widget.routeNodeIds.isEmpty) {
        throw Exception("Gelen rota düğüm listesi boş. Lütfen Ana Ekran'da rota hesaplandığından emin olun.");
      }

      // Gerçek senaryoda burası doğrudan NavigationService'den gelirdi.
      // Sunum demosunu güçlendirmek için, Amfi 5 -> Gastronomi rotasını
      // senin ölçümlerine göre detaylandırıyoruz. (Mühendislik Fakültesi - Kat 1 varsayımı)
      if (widget.startLocation.id == 'A5' && widget.endLocation.id == 'GM') {

        // Mock detaylı rota adımları (Senin gözlemlerine göre oluşturuldu)
        fullRouteLocations = [
          widget.startLocation, // 0. Amfi 5
          Location(id: 'KOR-10M', name: '10m Koridor', x: 10, y: 5, floor: 1, type: 'Koridor'), // 1. 10m İleri
          Location(id: 'DONUS-SOL', name: 'Sol Dönüş Noktası', x: 10, y: 7, floor: 1, type: 'Köşe'), // 2. 2m Sol
          Location(id: 'DONUS-SAG', name: 'Sağ Dönüş Noktası', x: 10.5, y: 7, floor: 1, type: 'Köşe'), // 3. 0.5m Sağ
          Location(id: 'A4', name: 'Amfi 4 Önü', x: 11, y: 7, floor: 1, type: 'Amfi'), // 4. Amfi 4 Önü (Hedefe çok yakın)
          Location(id: 'GM', name: 'Gastronomi Mutfağı (Hedef)', x: 12, y: 7, floor: 1, type: 'Sınıf'), // 5. Hedef
        ];

      } else {
        // Eğer rota Amfi 5-GM değilse, orijinal sade rota mantığını kullan.
        fullRouteLocations = widget.routeNodeIds
            .map((id) => _navigationService.getLocationById(id))
            .toList();
      }

      if (fullRouteLocations.isEmpty) {
        throw Exception("Rota düğümleri yüklendi, ancak liste boş kaldı. Veri tutarsızlığı var.");
      }

    } catch (e) {
      // Hata durumunda _loadingError'ı ayarla
      _loadingError = 'Hata: Rota verisi yüklenemedi. Bilgi: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false; // Yükleme bitti
      });
    }
  }

  // Sonraki adıma geç
  void _nextStep() {
    if (currentStepIndex < fullRouteLocations.length - 1) {
      setState(() {
        currentStepIndex++;
      });
    } else {
      // Hedefe ulaşıldı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🎉 Hedefinize ulaştınız!'), duration: Duration(seconds: 3)),
      );
      // Hedefe ulaşıldıktan sonra butonu devre dışı bırak
      setState(() {
        currentStepIndex = fullRouteLocations.length - 1;
      });
    }
  }

  // Yön ikonunu hesaplar (Mock)
  IconData _getDirectionIcon(Location? nextLocation, Location currentLocation) {
    if (nextLocation == null) return Icons.flag_circle; // Hedef

    // Kat değiştirme kontrolü
    if (nextLocation != null && nextLocation.floor != currentLocation.floor) {
      return nextLocation.floor > currentLocation.floor ? Icons.stairs : Icons.stairs_outlined;
    }

    // Yönlendirme mantığı (Yeni detaylı adımlara göre)
    final String nextId = nextLocation?.id ?? '';

    switch (currentStepIndex) {
      case 0: // Amfi 5'ten çıkış
        return Icons.arrow_upward; // Düz git
      case 1: // 10m ilerideki dönüşten önceki adım
        return Icons.turn_left; // Sola dön
      case 2: // Sola dönüldü, şimdi 0.5m sağa
        return Icons.turn_right; // Sağa dön
      default:
      // Diğer adımlar veya düz ilerle
        return Icons.arrow_upward;
    }
  }

  // Yönlendirme metnini yeni detaylı adımlara göre hesaplar.
  String _getDirectionText(Location? nextLocation, int currentIndex) {
    if (nextLocation == null) {
      return '🎉 Hedef: ${widget.endLocation.name}';
    }

    if (nextLocation.floor != fullRouteLocations[currentIndex].floor) {
      final direction = nextLocation.floor > fullRouteLocations[currentIndex].floor ? 'yukarı' : 'aşağı';
      return 'Merdivenleri kullanarak ${nextLocation.floor}. kata $direction çıkın.';
    }

    // Yeni, detaylı komutlar
    switch (currentIndex) {
      case 0:
        return '🚶 Amfi 5\'ten çıkın ve 10 metre boyunca düz ilerleyin.';
      case 1:
        return '↩️ Sola dönün ve 2 metre daha ilerleyin.';
      case 2:
        return '↪️ Sağ tarafa kısa bir dönüş yapın (0.5 metre).';
      case 3:
        return '🧭 Amfi 4 kapısı solunuzda. 1 metre daha ilerleyin.';
      case 4:
        return '🎉 Gastronomi Mutfağı (Hedef) tam önünüzde!';
      default:
        return '🚶 ${nextLocation.name} konumuna doğru ilerleyin.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('AR Navigasyon (Yükleniyor...)')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadingError != null) {
      // Hata ekranı: Ana menüye dönme butonu ile hatayı gösterir.
      return Scaffold(
        appBar: AppBar(
          title: Text('Hata!'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 60),
                SizedBox(height: 20),
                Text(
                  'Rota Verisi Hatası',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  _loadingError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back),
                  label: Text('Ana Menüye Dön'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentLocation = fullRouteLocations[currentStepIndex];
    final nextLocation = currentStepIndex < fullRouteLocations.length - 1
        ? fullRouteLocations[currentStepIndex + 1]
        : null;

    // Mock Koordinatlar (Simülasyon için)
    final double currentX = currentLocation.x;
    final double currentY = currentLocation.y;

    final String directionText = _getDirectionText(nextLocation, currentStepIndex);

    final String floorInfo = 'Kat: ${currentLocation.floor} / Hedef Kat: ${widget.endLocation.floor} (Mühendislik Fak.)';

    return Scaffold(
      appBar: AppBar(
        title: Text('AR Navigasyon (Simülasyon)'),
        backgroundColor: Colors.indigo,
      ),
      body: Stack(
        children: [
          // ----------------------------------------------------
          // AR SIMÜLASYON ZEMİNİ (Burada Kamera Görüntüsü Olacaktı)
          // Hoca'ya sunumda buraya koridor fotoğrafı koyduğunu söyle.
          Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Konumlandırma Varsayımı
                  Text('📍 Konum Varsayımı: ${currentLocation.name} Önü',
                      style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),

                  SizedBox(height: 20),

                  // Gerçek AR Okları yerine büyük bir yön oku
                  Icon(_getDirectionIcon(nextLocation, currentLocation), size: 100, color: nextLocation == null ? Colors.green[800] : Colors.green),

                  SizedBox(height: 10),
                  Text(nextLocation != null ? 'SONRAKİ ADIM' : 'HEDEF!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),

                  // Mevcut Rota Durumu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mevcut Düğüm:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('${currentLocation.name} (${currentLocation.id})', style: TextStyle(fontSize: 20, color: Colors.blue[800])),
                            Divider(),
                            Text('Sonraki Düğüm:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(nextLocation?.name ?? 'Gastronomi Mutfağı', style: TextStyle(fontSize: 20, color: Colors.green[800])),
                            Divider(),
                            Text(
                              'Mock Koordinatlar: X: ${currentX.toStringAsFixed(2)}, Y: ${currentY.toStringAsFixed(2)}',
                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // ----------------------------------------------------

          // Yönlendirme Paneli (Altta)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(directionText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3), textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  Text(floorInfo, style: TextStyle(fontSize: 16, color: Colors.black54)),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: nextLocation != null ? _nextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: nextLocation != null ? Colors.indigo : Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text(
                        nextLocation != null ? 'Adımı Tamamla / Devam Et' : 'Navigasyonu Bitir',
                        style: TextStyle(color: Colors.white)
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
