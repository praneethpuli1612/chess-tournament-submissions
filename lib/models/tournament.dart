class Tournament {
  final int? id;
  final String name;
  final String location;

  Tournament({
    this.id,
    required this.name,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
    };
  }

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      id: map['id'],
      name: map['name'],
      location: map['location'],
    );
  }
}