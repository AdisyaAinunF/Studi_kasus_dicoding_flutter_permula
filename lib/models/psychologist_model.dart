class PsychologistModel {
  final String id;
  final String name;
  final String hospital;
  final String schedule;
  final String imageUrl;
  final double rating;

  PsychologistModel({
    required this.id,
    required this.name,
    required this.hospital,
    required this.schedule,
    required this.imageUrl,
    required this.rating,
  });

  factory PsychologistModel.fromMap(String id, Map<String, dynamic> m) {
    return PsychologistModel(
      id: id,
      name: m['name'] ?? '',
      hospital: m['hospital'] ?? '',
      schedule: m['schedule'] ?? '',
      imageUrl: m['imageUrl'] ?? '',
      rating: (m['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'hospital': hospital,
        'schedule': schedule,
        'imageUrl': imageUrl,
        'rating': rating,
      };
}