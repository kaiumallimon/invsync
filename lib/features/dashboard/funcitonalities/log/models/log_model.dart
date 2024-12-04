class Log {
  final String id;
  final String operation;
  final Map<String, dynamic> data;
  final String timestamp;

  Log({
    required this.id,
    required this.operation,
    required this.data,
    required this.timestamp,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['_id'],
      operation: json['operation'],
      data: json['data'],
      timestamp: json['timestamp'],
    );
  }
}
