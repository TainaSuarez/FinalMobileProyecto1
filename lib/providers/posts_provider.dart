import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post_model.dart';
import '../helpers/database_helper.dart';

class PostsProvider with ChangeNotifier {
  final List<Post> _posts = [];
  final List<Post> _favoritePosts = [];
  List<Post> _filteredPosts = [];
  bool _isLoading = false;

  // Getters
  List<Post> get posts => List.unmodifiable(_posts);
  List<Post> get favoritePosts => List.unmodifiable(_favoritePosts);
  List<Post> get filteredPosts => List.unmodifiable(_filteredPosts);
  bool get isLoading => _isLoading;

  PostsProvider() {
    _filteredPosts = _posts; // Inicialmente, mostrar todos los posts.
  }

  // Obtener Pokémon de la API
  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Obtener la lista de Pokémon de la API
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=50'), // Traer 50 Pokémon
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        final pokemonUrls = (jsonResponse['results'] as List)
            .map((item) => item['url'] as String)
            .toList();

        _posts.clear();
        int index = 1;

        for (var url in pokemonUrls) {
          final pokemonResponse = await http.get(Uri.parse(url));

          if (pokemonResponse.statusCode == 200) {
            final Map<String, dynamic> pokemonData =
                json.decode(pokemonResponse.body);
            _posts.add(Post.fromJson(pokemonData, index++));
          } else {
            debugPrint('Error obteniendo Pokémon: ${pokemonResponse.statusCode}');
          }
        }

        _filteredPosts = List.from(_posts); // Copia inicial para los filtros.
        notifyListeners();
      } else {
        debugPrint('Error obteniendo lista de Pokémon: ${response.statusCode}');
        _posts.clear();
        _filteredPosts.clear();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al obtener Pokémon: $e');
      _posts.clear();
      _filteredPosts.clear();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  // Filtrar publicaciones por tipo de Pokémon
  Future<void> filterPosts(String type) async {
    if (type == 'All') {
      _filteredPosts = List.from(_posts);
    } else {
      try {
        final response = await http.get(
          Uri.parse('https://pokeapi.co/api/v2/type/${type.toLowerCase()}'),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);

          final pokemonNames = (jsonResponse['pokemon'] as List)
              .map((item) => item['pokemon']['name'] as String)
              .toSet();

          _filteredPosts = _posts.where((post) {
            return pokemonNames.contains(post.title.toLowerCase());
          }).toList();
        } else {
          debugPrint('Error obteniendo tipo $type: ${response.statusCode}');
          _filteredPosts = [];
        }
      } catch (e) {
        debugPrint('Error al filtrar por tipo: $e');
        _filteredPosts = [];
      }
    }
    notifyListeners();
  }

  // Obtener publicaciones favoritas de la base de datos local
  Future<void> fetchFavoritePosts() async {
    try {
      final favorites = await DatabaseHelper.instance.getFavorites();
      _favoritePosts.clear();
      _favoritePosts.addAll(favorites);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al obtener favoritos: $e');
    }
  }

  // Alternar el estado de favorito
  Future<void> toggleFavorite(Post post) async {
    try {
      post.isFavorite = !post.isFavorite;

      if (post.isFavorite) {
        await DatabaseHelper.instance.insertFavorite(post);
      } else {
        await DatabaseHelper.instance.deleteFavorite(post.id);
      }

      await fetchFavoritePosts();
    } catch (e) {
      debugPrint('Error al cambiar favorito: $e');
    } finally {
      notifyListeners();
    }
  }
}
