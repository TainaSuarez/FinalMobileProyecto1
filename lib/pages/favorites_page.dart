import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key}); // Using super.key

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, postsProvider, child) {
        // Manejar la lista vacía de favoritos
        if (postsProvider.favoritePosts.isEmpty) {
          return const Center(
            child: Text(
              'No favorite posts yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // Crear la lista de favoritos
        return ListView.builder(
          itemCount: postsProvider.favoritePosts.length,
          itemBuilder: (context, index) {
            final post = postsProvider.favoritePosts[index];

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  post.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  post.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _confirmDelete(context, postsProvider, post);
                  },
                ),
                onTap: () {
                  _showPostDetails(context, post);
                },
              ),
            );
          },
        );
      },
    );
  }

  // Mostrar diálogo de confirmación antes de eliminar un favorito
  void _confirmDelete(BuildContext context, PostsProvider postsProvider, dynamic post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to remove this post from favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cerrar diálogo
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              postsProvider.toggleFavorite(post);
              Navigator.pop(context); // Cerrar diálogo
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Mostrar detalles del post en un diálogo
  void _showPostDetails(BuildContext context, dynamic post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(post.title),
        content: Text(post.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cerrar diálogo
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
