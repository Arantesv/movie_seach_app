import 'package:flutter/material.dart';

/// Exibe uma linha de informação com um ícone e texto.
///
/// [icon] é o ícone que será exibido à esquerda do texto, e [info] é a string
/// de texto que contém a informação a ser exibida.
class MovieInfoRow extends StatelessWidget {
  const MovieInfoRow({super.key, required this.icon, required this.info});

  final IconData icon;
  final String info;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: screenWidth * 0.045, color: Colors.grey),
        SizedBox(width: screenWidth * 0.015),
        Expanded(
          child: Text(
            info,
            style: TextStyle(color: Colors.grey[400], fontSize: screenWidth * 0.04),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
