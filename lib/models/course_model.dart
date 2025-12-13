class Course {
  final String id; // UUID dari Supabase
  final String name;
  final String? lecturer;
  final String? room;
  final String? colorCode;

  Course({
    required this.id,
    required this.name,
    this.lecturer,
    this.room,
    this.colorCode,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'] ?? 'Tanpa Nama',
      lecturer: json['lecturer'],
      room: json['room'],
      colorCode: json['color_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lecturer': lecturer,
      'room': room,
      'color_code': colorCode,
    };
  }
}
