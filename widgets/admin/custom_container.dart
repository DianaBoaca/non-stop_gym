import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({super.key, required this.icon, required this.title, required this.color, required this.route});

  final IconData icon;
  final String title;
  final Color color;
  final Widget route;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
          size: 25,
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
        tileColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => route),
          );
        },
      ),
    );
  }
}


