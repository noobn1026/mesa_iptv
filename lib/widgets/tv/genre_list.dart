import 'package:flutter/material.dart';
import '../../models/channel_model.dart';
import 'genre_item.dart';
import '../../utils/constants.dart';

class GenreList extends StatelessWidget {
  final List<Section> sections;
  final String? selectedGenre;
  final Function(String) onGenrePress;
  final VoidCallback onSettingsPress;

  const GenreList({
    super.key,
    required this.sections,
    required this.selectedGenre,
    required this.onGenrePress,
    required this.onSettingsPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.sidebarColor,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              border: Border(bottom: BorderSide(color: Constants.borderColor)),
            ),
            child: Row(
              children: [
                const Text(
                  '📺 GENRES',
                  style: TextStyle(
                    color: Color(0xFFe50914),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a2a),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${sections.length}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                // Settings button
                GestureDetector(
                  onTap: onSettingsPress,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a2a2a),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.settings, size: 18, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          // Genre list
          Expanded(
            child: ListView.builder(
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                final isActive = selectedGenre == section.title;
                return GenreItem(
                  title: section.title,
                  count: section.data.length,
                  isActive: isActive,
                  onPressed: () => onGenrePress(section.title),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}