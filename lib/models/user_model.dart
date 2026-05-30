class User {
  final String? id;
  final String? username;
  final String? name;
  final String? email;
  final String? expiryDate;
  final Map<String, dynamic>? customer;

  User({
    this.id,
    this.username,
    this.name,
    this.email,
    this.expiryDate,
    this.customer,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString(),
      username: json['username']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      expiryDate: json['expiryDate'] ?? json['customer']?['expiryDate'],
      customer: json['customer'],
    );
  }

  DateTime? get expiryDateTime {
    if (expiryDate == null) return null;
    try {
      return DateTime.parse(expiryDate!);
    } catch (_) {
      return null;
    }
  }

  bool get isExpired {
    final expiry = expiryDateTime;
    if (expiry == null) return false;
    return expiry.isBefore(DateTime.now());
  }

  int get daysRemaining {
    final expiry = expiryDateTime;
    if (expiry == null) return -1;
    return expiry.difference(DateTime.now()).inDays;
  }
}