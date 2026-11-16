import 'package:flutter/material.dart';

class TrailerText extends StatelessWidget {
  const TrailerText({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.play_arrow,
              size: width * 0.045,
              color: Colors.grey[300],
            ),
            SizedBox(width: width * 0.015),
            Text(
              'Reproduzir trailer',
              style: TextStyle(
                fontSize: width * 0.04,
                color: Colors.grey[300],
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
