import 'package:flutter/material.dart';
import '../../models/channel_model.dart';
import 'genre_list.dart';
import 'channel_list.dart';
import '../../utils/constants.dart';

class Sidebar extends StatelessWidget {
  final List<Section> sections;
  final String? selectedGenre;
  final List<Channel> channels;
  final Channel? currentChannel;
  final Channel? lastChannel;
  final Channel? previewChannel;
  final Function(String) onGenrePress;
  final Function(Channel) onChannelPress;
  final Function(Channel) onChannelFocus;
  final String viewMode;
  final VoidCallback onBackToCategories;
  final VoidCallback onSettingsPress;

  const Sidebar({
    super.key,
    required this.sections,
    required this.selectedGenre,
    required this.channels,
    required this.currentChannel,
    required this.lastChannel,
    this.previewChannel,
    required this.onGenrePress,
    required this.onChannelPress,
    required this.onChannelFocus,
    required this.viewMode,
    required this.onBackToCategories,
    required this.onSettingsPress,
  });

  @override
  Widget build(BuildContext context) {
    return viewMode == 'categories'
        ? GenreList(
            sections: sections,
            selectedGenre: selectedGenre,
            onGenrePress: onGenrePress,
            onSettingsPress: onSettingsPress,
          )
        : ChannelList(
            channels: channels,
            selectedGenre: selectedGenre,
            currentChannel: currentChannel,
            lastChannel: lastChannel,
            previewChannel: previewChannel,
            onChannelPress: onChannelPress,
            onChannelFocus: onChannelFocus,
            onSettingsPress: onSettingsPress,
            onBack: onBackToCategories,
          );
  }
}