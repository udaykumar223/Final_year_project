/// SmartCrop AI — Crop Model
class Crop {
  final String id;
  final String name;
  final String displayName;
  final String emoji;
  final String description;
  final List<String> diseases;
  final bool isEnabled;

  const Crop({
    required this.id,
    required this.name,
    required this.displayName,
    required this.emoji,
    required this.description,
    required this.diseases,
    this.isEnabled = true,
  });

  int get diseaseCount => diseases.length;

  /// Phase 1 crops — generated from the actual dataset
  static const List<Crop> availableCrops = [
    Crop(
      id: 'banana',
      name: 'Banana',
      displayName: 'Banana',
      emoji: '\u{1F34C}',
      description: 'Detect 8 diseases including Sigatoka, Panama, and Moko',
      diseases: [
        'Bract Mosaic Virus', 'Cordana', 'Healthy', 'Insect Pest',
        'Moko', 'Panama', 'Pestalotiopsis', 'Sigatoka', 'Yellow Sigatoka',
      ],
    ),
    Crop(
      id: 'groundnut',
      name: 'Groundnut',
      displayName: 'Groundnut',
      emoji: '\u{1F95C}',
      description: 'Detect 5 diseases including Leaf Spot and Rust',
      diseases: [
        'Early Leaf Spot', 'Early Rust', 'Healthy',
        'Late Leaf Spot', 'Nutrition Deficiency', 'Rust',
      ],
    ),
    Crop(
      id: 'radish',
      name: 'Radish',
      displayName: 'Radish',
      emoji: '\u{1F958}',
      description: 'Detect 4 diseases including Downy Mildew and Mosaic',
      diseases: [
        'Black Leaf Spot', 'Downy Mildew', 'Flea Beetle',
        'Healthy', 'Mosaic',
      ],
    ),
  ];

  static const List<Crop> defaults = availableCrops;
}
