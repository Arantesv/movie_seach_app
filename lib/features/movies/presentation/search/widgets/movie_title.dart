import 'package:flutter/material.dart';

/// Exibe o título do filme.
class MovieTitle extends StatelessWidget {
  const MovieTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Text(
      title,
      style: TextStyle(
        fontSize: screenWidth * 0.045,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
