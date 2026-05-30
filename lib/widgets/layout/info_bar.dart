import 'package:flutter/material.dart';
import '../../models/channel_model.dart';
import '../../utils/constants.dart';

class InfoBar extends StatelessWidget {
  final Channel? currentChannel;
  final Channel? lastChannel;
  final VoidCallback onLastChannelPress;
  final String playbackMode;

  const InfoBar({
    super.key,
    required this.currentChannel,
    required this.lastChannel,
    required this.onLastChannelPress,
    required this.playbackMode,
  });

  @override
  Widget build(BuildContext context) {
    if (currentChannel == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Constants.sidebarColor,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tv, color: Colors.grey),
            SizedBox(width: 8),
            Text('Select a channel to start watching', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final isDirectMode = playbackMode == 'direct';

    return Container(
      padding: const EdgeInsets.all(12),
      color: Constants.sidebarColor,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Constants.sidebarLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tv, size: 22, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentChannel!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (currentChannel!.group != null)
                      Text(
                        currentChannel!.group!,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (currentChannel!.isHd)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a3a5c),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('HD', style: TextStyle(color: Color(0xFF4fc3f7), fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: isDirectMode ? Constants.primaryColor : Constants.lastChannel),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDirectMode ? Icons.flash_on : Icons.swap_horiz,
                      size: 10,
                      color: isDirectMode ? Constants.primaryColor : Constants.lastChannel,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDirectMode ? 'DIRECT' : 'PROXY',
                      style: TextStyle(
                        color: isDirectMode ? Constants.primaryColor : Constants.lastChannel,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (lastChannel != null)
                GestureDetector(
                  onTap: onLastChannelPress,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Constants.lastChannel.withOpacity(0.1),
                      border: Border.all(color: Constants.lastChannel.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.undo, size: 12, color: Color(0xFFf9a825)),
                        const SizedBox(width: 4),
                        Text(
                          lastChannel!.name,
                          style: const TextStyle(color: Color(0xFFf9a825), fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              const Text(
                '↑↓ Browse · ← Genres · → Last · OK Play/Pause',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}