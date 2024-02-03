import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/busy_indicator.dart';
import 'package:non_stop_gym/widgets/client_card.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            const ClientCard(),
            const SizedBox(height: 20),
            BusyIndicator(),
          ],
    );
  }
}
