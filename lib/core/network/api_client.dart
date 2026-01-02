import 'package:http/http.dart' as http;

class ApiClient {
  const ApiClient();

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    return http.get(uri, headers: headers);
  }
}
