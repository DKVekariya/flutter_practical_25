import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../data/models/word.dart';

class WordDetails extends StatelessWidget {
  final Word word;
  final AudioPlayer _audioPlayer = AudioPlayer();

  WordDetails({super.key, required this.word});

  void _playPronunciation(String? audioUrl) async {
    if (audioUrl != null && audioUrl.isNotEmpty) {
      try {
        await _audioPlayer.play(UrlSource(audioUrl));
      } catch (e) {
        // Handle playback error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pronunciation = word.phonetics.firstWhere(
          (p) => p.audio != null && p.audio!.isNotEmpty,
      orElse: () => Phonetic(),
    );

    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  if (pronunciation.audio != null)
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.amber),
                      onPressed: () => _playPronunciation(pronunciation.audio),
                    ),
                ],
              ),
              if (word.phonetic != null)
                Text(
                  word.phonetic!,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 16),
              ...word.meanings.asMap().entries.map((entry) {
                final meaning = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meaning.partOfSpeech.capitalize(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...meaning.definitions.asMap().entries.map((defEntry) {
                      final definition = defEntry.value;
                      return Container(
                        margin: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${defEntry.key + 1}. ${definition.definition}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (definition.example != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Example: ${definition.example}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            if (definition.synonyms.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Synonyms: ${definition.synonyms.join(', ')}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}