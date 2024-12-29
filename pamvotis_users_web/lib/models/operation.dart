import 'dart:convert';

class Operation {
  final String type;
  final int timestampInMs;
  final String dataJson;

  Operation({
    required this.type,
    Map<String, dynamic>? data,
  }) : timestampInMs = DateTime.now().millisecondsSinceEpoch,
        dataJson = data != null ? jsonEncode(data) : '{}';

  Map<String, dynamic> get data => jsonDecode(dataJson);
}