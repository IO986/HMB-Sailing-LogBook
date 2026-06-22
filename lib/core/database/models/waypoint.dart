class Waypoint {
  late String name;
  late double latitude;
  late double longitude;

  String? description;
  String? type; // 'anchor', 'marina', 'danger', 'custom'
  int color = 0xFF1A5276;

  late DateTime createdAt;

  bool isFavorite = false;
}
