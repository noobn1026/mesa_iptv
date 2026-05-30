import '../models/channel_model.dart';

String getChannelId(Channel? channel) {
  if (channel == null) return '';
  return channel.channelId ?? channel.id ?? '';
}

bool isSameChannel(Channel? channel1, Channel? channel2) {
  if (channel1 == null || channel2 == null) return false;
  return getChannelId(channel1) == getChannelId(channel2);
}

List<Section> groupChannelsByGenre(List<Channel> channels) {
  if (channels.isEmpty) return [];
  
  final Map<String, List<Channel>> genreMap = {};
  
  for (final channel in channels) {
    final genre = channel.group ?? channel.category ?? 'General';
    genreMap.putIfAbsent(genre, () => []).add(channel);
  }
  
  final sortedKeys = genreMap.keys.toList()..sort((a, b) => a.compareTo(b));
  return sortedKeys.map((key) => Section(title: key, data: genreMap[key]!)).toList();
}

List<Channel> sortChannelsByName(List<Channel> channels) {
  if (channels.isEmpty) return [];
  final sorted = List<Channel>.from(channels);
  sorted.sort((a, b) => a.name.compareTo(b.name));
  return sorted;
}

List<Channel> filterChannelsBySearch(List<Channel> channels, String query) {
  if (channels.isEmpty) return [];
  if (query.trim().isEmpty) return channels;
  final lowerQuery = query.toLowerCase();
  return channels.where((ch) => ch.name.toLowerCase().contains(lowerQuery)).toList();
}

int findChannelIndex(List<Channel> channels, String? channelId) {
  if (channels.isEmpty || channelId == null) return -1;
  return channels.indexWhere((ch) => getChannelId(ch) == channelId);
}

Channel? getNextChannel(List<Channel> channels, String? currentId) {
  if (channels.isEmpty) return null;
  if (currentId == null) return channels.first;
  
  final idx = findChannelIndex(channels, currentId);
  if (idx == -1) return channels.first;
  if (idx >= channels.length - 1) return channels.first;
  return channels[idx + 1];
}

Channel? getPreviousChannel(List<Channel> channels, String? currentId) {
  if (channels.isEmpty) return null;
  if (currentId == null) return channels.last;
  
  final idx = findChannelIndex(channels, currentId);
  if (idx == -1) return channels.last;
  if (idx <= 0) return channels.last;
  return channels[idx - 1];
}