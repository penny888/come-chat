// API service
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3100/api'; // Android模拟器访问本机

  Stream<String> streamChat(String message, String? conversationId, bool useRag) async* {

    log('message: ' + message);

    final url = Uri.parse('$baseUrl/chat/stream');
    final request = http.Request('POST', url);
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'message': message,
      'conversationId': conversationId,
      'useRag': useRag,
    });
    final streamedResponse = await request.send();
    final stream = streamedResponse.stream.transform(utf8.decoder);
    String buffer = '';
    await for (var chunk in stream) {
      buffer += chunk;
      // 解析SSE: data: {...}\n\n
      final lines = buffer.split('\n\n');
      buffer = lines.last;
      for (var i = 0; i < lines.length - 1; i++) {
        final line = lines[i];
        if (line.startsWith('data: ')) {
          final jsonStr = line.substring(6);
          final data = jsonDecode(jsonStr);
          if (data.containsKey('chunk')) {
            yield data['chunk'] as String;
          }
          if (data.containsKey('done')) {
            // 完成
            return;
          }
          if (data.containsKey('error')) {
            throw Exception(data['error']);
          }
        }
      }
    }
  }
}