import 'dart:io';
import 'dart:convert';

const int backendPort = 8000;

Future<void> main() async {
  final server = await HttpServer.bind('localhost', backendPort);
  print('Backend server listening on localhost:$backendPort');

  // Enable CORS headers
  server.defaultResponseHeaders.add('Access-Control-Allow-Origin', '*');
  server.defaultResponseHeaders.add(
      'Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  server.defaultResponseHeaders.add('Access-Control-Allow-Methods', 'POST, OPTIONS');

  await for (HttpRequest request in server) {
    if (request.method == 'OPTIONS') {
      // Handle preflight request
      request.response
        ..statusCode = HttpStatus.ok
        ..close();
    } else if (request.uri.path == '/login' && request.method == 'POST') {
      // Handle actual POST request
      try {
        final requestBody = await utf8.decoder.bind(request).join();
        final requestData = json.decode(requestBody);

        final email = requestData['email'];
        final password = requestData['password'];

        print('Email: $email');
        print('Password: $password');

        if (email == 'admin@example.com' && password == 'admin') {
          final responseBody = json.encode({'message': 'Login successful'});
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(responseBody);
        } else {
          final responseBody = json.encode({'message': 'Invalid credentials'});
          request.response
            ..statusCode = HttpStatus.unauthorized
            ..headers.contentType = ContentType.json
            ..write(responseBody);
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Invalid JSON');
      }
    } else {
      request.response.statusCode = HttpStatus.notFound;
    }

    await request.response.close();
  }
}
