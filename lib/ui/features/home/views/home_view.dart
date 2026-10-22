import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Activités')));
  }
}
