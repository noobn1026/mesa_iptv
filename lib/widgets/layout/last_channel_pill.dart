import 'package:flutter/material.dart';
import '../../models/channel_model.dart';
import '../../utils/constants.dart';

class LastChannelPill extends StatelessWidget {
  final Channel channel;
  final VoidCallback onPress;

  const LastChannelPill({
    super.key,
    required this.channel,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          border: Border.all(color: Constants.lastChannel),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.undo, size: 12, color: Color(0xFFf9a825)),
            const SizedBox(width: 4),
            Text(
              channel.name,
              style: const TextStyle(color: Color(0xFFf9a825), fontSize: 11, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}