class Tournament {
  final int? id;
  final String name;
  final String location;

  Tournament({
    this.id,
    required this.name,
    required this.location,
  });

  Tournament copyWith({
    int? id,
    String? name,
    String? location,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
    };
  }

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      id: map['id'] as int?,
      name: map['name'] as String,
      location: map['location'] as String,
    );
  }
}