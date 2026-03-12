import 'package:flutter/material.dart';

class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.error, color: Colors.red, size: 50),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
