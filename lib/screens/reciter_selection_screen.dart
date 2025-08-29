import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart'; // Assuming you have an AudioProvider to manage reciters

class ReciterSelectionScreen extends StatelessWidget {
  const ReciterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر القارئ'),
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          if (audioProvider.reciters.isEmpty) {
            return const Center(
              child: Text('لا توجد قراء متاحين'),
            );
          } else {
            return ListView.builder(
              itemCount: audioProvider.reciters.length,
              itemBuilder: (context, index) {
                final reciter = audioProvider.reciters[index];
                return ListTile(
                  title: Text(reciter.name),
                  onTap: () {
                    audioProvider.selectReciter(reciter);
                    Navigator.pop(context);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
