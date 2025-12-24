import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  final List<String> categories = const [
    'Name',
    'Animal',
    'City',
    'Object',
    'Food',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Letter Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'A',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Categories
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: categories[index],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Stop Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                 // Navigator.push(
                   // context,
                   // MaterialPageRoute(builder: (_) => const ScoreScreen()),
                 // );
                },
                child: const Text('STOP'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
