import 'package:flutter/material.dart';

class CustomRow extends StatelessWidget {
  const CustomRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}