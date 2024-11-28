import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedFilter = 'All';

  void _applyFilter(String filter, PostsProvider postsProvider) {
    setState(() {
      _selectedFilter = filter;
    });
    postsProvider.filterPosts(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, postsProvider, child) {
        if (postsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (postsProvider.filteredPosts.isEmpty) {
          return const Center(
            child: Text(
              'No Pokémon found!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            // Dropdown Filtros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Pokémon by Type:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: _selectedFilter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Fire', child: Text('Fire')),
                      DropdownMenuItem(value: 'Water', child: Text('Water')),
                      DropdownMenuItem(value: 'Grass', child: Text('Grass')),
                      DropdownMenuItem(value: 'Electric', child: Text('Electric')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _applyFilter(value, postsProvider);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0), // Espaciado reducido
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Cuatro cartas por línea
                    mainAxisSpacing: 4.0, // Espaciado reducido entre filas
                    crossAxisSpacing: 4.0, // Espaciado reducido entre columnas
                    childAspectRatio: 0.8, // Ajustar tamaño vertical
                  ),
                  itemCount: postsProvider.filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = postsProvider.filteredPosts[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Imagen del Pokémon
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                              child: Image.network(
                                post.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Información del Pokémon
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 4.0,
                              ), // Espaciado interno reducido
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.title.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2), // Espaciado reducido
                                  Text(
                                    'Base Exp: ${post.body}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Botón de favorito
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: IconButton(
                              icon: Icon(
                                post.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: post.isFavorite ? Colors.red : null,
                                size: 20, // Icono más pequeño
                              ),
                              onPressed: () => postsProvider.toggleFavorite(post),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
