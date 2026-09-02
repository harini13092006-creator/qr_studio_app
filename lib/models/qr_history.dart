class QRHistory {
  final String id;
  final String type;
  final String data;
  final DateTime createdAt;

  const QRHistory({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory QRHistory.fromJson(Map<String, dynamic> json) {
    return QRHistory(
      id: json['id'] as String,
      type: json['type'] as String,
      data: json['data'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get displayTitle {
    switch (type) {
      case 'URL':
        return 'Website QR';
      case 'Email':
        return 'Email QR';
      case 'Phone':
        return 'Phone QR';
      case 'Wi-Fi':
        return 'Wi-Fi QR';
      default:
        return 'Text QR';
    }
  }
}