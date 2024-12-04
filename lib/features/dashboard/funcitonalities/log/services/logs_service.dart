import 'dart:convert';
import 'package:http/http.dart' as http;

class LogService {
  final String _url = 'https://invsync.bcrypt.website/logs/get';

  Future<Map<String, dynamic>> fetchLogs(int page, int limit) async {
    final response = await http.get(Uri.parse('$_url?page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load logs');
    }
  }
}
