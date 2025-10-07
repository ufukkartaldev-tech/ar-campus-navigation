// Bu dosya, haritadaki her bir düğümü (Node) temsil eder.
// Sınıf, koridor girişi, merdiven, bina girişi... hepsi bir Location'dır.

class Location {
  final String id; // Graph'ta kullanılacak benzersiz ID (örn: 'd201')
  final String name; // Kullanıcıya gösterilecek isim (örn: 'D201 Sınıfı')
  final String? parentId; // Hangi binaya veya alana bağlı olduğu (örn: 'muhendislik')
  final String type; // Tipi (örn: 'classroom', 'corridor', 'stairs')
  final String description;
  final int floor; // Kat bilgisi (0: zemin, 1: birinci kat vb.)
  final bool isBuilding; // Bu bir bina mı yoksa bina içi bir yer mi?

  // AR ve A* için kritik olan koordinatlar (Mock verilerdir!)
  // x: soldan sağa, y: yukarıdan aşağıya (metre biriminde varsayalım)
  final double x;
  final double y;

  Location({
    required this.id,
    required this.name,
    this.parentId,
    required this.type,
    required this.description,
    required this.floor,
    this.isBuilding = false,
    required this.x,
    required this.y,
  });
}
