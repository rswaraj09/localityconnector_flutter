class Category {
  final int? id;
  final String name;
  final String? description;
  final String? icon;

  Category({
    this.id,
    required this.name,
    this.description,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
    );
  }
} 