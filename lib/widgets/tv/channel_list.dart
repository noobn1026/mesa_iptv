import 'package:flutter/material.dart';
import '../../models/channel_model.dart';
import 'channel_item.dart';
import '../../utils/constants.dart';
import '../../utils/channel_helpers.dart';

class ChannelList extends StatelessWidget {
  final List<Channel> channels;
  final String? selectedGenre;
  final Channel? currentChannel;
  final Channel? lastChannel;
  final Channel? previewChannel;
  final Function(Channel) onChannelPress;
  final Function(Channel) onChannelFocus;
  final VoidCallback onSettingsPress;
  final VoidCallback onBack;

  const ChannelList({
    super.key,
    required this.channels,
    required this.selectedGenre,
    required this.currentChannel,
    required this.lastChannel,
    this.previewChannel,
    required this.onChannelPress,
    required this.onChannelFocus,
    required this.onSettingsPress,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0f0f0f),
      child: Column(
        children: [
          // Header with back button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              border: Border(bottom: BorderSide(color: Constants.borderColor)),
            ),
            child: Row(
              children: [
                // Back button
                _buildHeaderButton(
                  icon: Icons.arrow_back,
                  onPressed: onBack,
                  iconColor: Constants.primaryColor,
                ),
                const SizedBox(width: 8),
                // Title
                Expanded(
                  child: Text(
                    selectedGenre?.toUpperCase() ?? 'ALL CHANNELS',
                    style: const TextStyle(
                      color: Color(0xFFe50914),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e1e1e),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${channels.length}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                // Settings button
                _buildHeaderButton(
                  icon: Icons.settings,
                  onPressed: onSettingsPress,
                  iconColor: Colors.grey,
                ),
              ],
            ),
          ),
          // Channel list
          Expanded(
            child: ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                final isPlaying = isSameChannel(channel, currentChannel);
                final isLast = isSameChannel(channel, lastChannel);
                final isPreviewing = previewChannel != null && isSameChannel(channel, previewChannel);
                
                return ChannelItem(
                  channel: channel,
                  isPlaying: isPlaying,
                  isLast: isLast,
                  isPreviewing: isPreviewing,
                  onPressed: () => onChannelPress(channel),
                  onFocus: onChannelFocus,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}