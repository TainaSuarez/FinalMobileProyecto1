class Post {
  final int id;
  final int userId;
  final String title;
  final String body;
  final String imageUrl;
  bool isFavorite;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.imageUrl,
    this.isFavorite = false,
  });

  // Convertir objeto Post a Map para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
    };
  }

  // Crear un objeto Post desde un Map obtenido de SQLite
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as int,
      userId: map['userId'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      imageUrl: map['imageUrl'] as String,
      isFavorite: false, // Los favoritos cargados desde la base de datos no están marcados por defecto
    );
  }

  // Crear un objeto Post desde JSON para Providers
  factory Post.fromJson(Map<String, dynamic> json, int index) {
    // Extraer habilidades como una lista separada por comas
    final abilities = (json['abilities'] as List)
        .map((ability) => ability['ability']['name'])
        .join(', ');

    return Post(
      id: index,
      userId: 1, // Usuario genérico
      title: json['name'] ?? 'Desconocido',
      body: 'Habilidades: $abilities\nExperiencia base: ${json['base_experience']}',
      imageUrl: json['sprites']['front_default'] ??
          'https://via.placeholder.com/150', // Imagen o placeholder
    );
  }
}
