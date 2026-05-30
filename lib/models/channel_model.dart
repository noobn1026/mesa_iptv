class Channel {
  final String? id;
  final String? channelId;
  final String name;
  final String? group;
  final String? category;
  final String? logo;
  final String? url;
  final String? cmd;
  final String? playlistId;
  final String? macAddress;
  final bool isHd;
  final String? playlistType;

  Channel({
    this.id,
    this.channelId,
    required this.name,
    this.group,
    this.category,
    this.logo,
    this.url,
    this.cmd,
    this.playlistId,
    this.macAddress,
    this.isHd = false,
    this.playlistType,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['_id']?.toString(),
      channelId: json['channelId']?.toString(),
      name: json['name'] ?? 'Unknown',
      group: json['group'] ?? json['category'],
      category: json['category'] ?? json['group'],
      logo: json['logo'],
      url: json['url'],
      cmd: json['cmd'],
      playlistId: json['playlistId']?.toString(),
      macAddress: json['macAddress'],
      isHd: json['isHd'] == true,
      playlistType: json['playlistType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'channelId': channelId,
      'name': name,
      'group': group,
      'category': category,
      'logo': logo,
      'url': url,
      'cmd': cmd,
      'playlistId': playlistId,
      'macAddress': macAddress,
      'isHd': isHd,
      'playlistType': playlistType,
    };
  }

  String get uniqueId => '$playlistId-$channelId';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Channel && other.uniqueId == uniqueId;
  }

  @override
  int get hashCode => uniqueId.hashCode;
}

class Section {
  final String title;
  final List<Channel> data;

  Section({required this.title, required this.data});
}