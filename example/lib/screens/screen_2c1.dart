import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Screen2c1 extends StatelessWidget {
  static const String routeName = 'screen2c1';

  const Screen2c1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Center(
            child: Text('Screen 2c1'),
          ),
          ElevatedButton(
            onPressed: context.pop,
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}
