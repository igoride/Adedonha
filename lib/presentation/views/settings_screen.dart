import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: vm.categories.length,
                itemBuilder: (_, index) {
                  return Card(
                    child: ListTile(
                      title: Text(vm.categories[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => vm.removeCategory(index),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Time per round (seconds)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: vm.timePerRound.toDouble(),
              min: 30,
              max: 300,
              divisions: 10,
              label: vm.timePerRound.toString(),
              onChanged: (value) {
                vm.setTimePerRound(value.toInt());
              },
            ),

            const SizedBox(height: 24),
            const Text(
              'Number of rounds',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: vm.totalRounds.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: vm.totalRounds.toString(),
              onChanged: (value) {
                vm.setTotalRounds(value.toInt());
              },
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'New category',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    vm.addCategory(_controller.text);
                    _controller.clear();
                  },
                ),
              ),
              onSubmitted: (value) {
                vm.addCategory(value);
                _controller.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
