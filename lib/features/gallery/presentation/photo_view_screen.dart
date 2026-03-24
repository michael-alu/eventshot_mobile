import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PhotoViewScreen extends StatelessWidget {
  const PhotoViewScreen({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: imageUrl,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
