import 'dart:convert';
import 'dart:typed_data';

import 'package:daily_life/services/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleTtsClient', () {
    test('sends Google TTS request and decodes audio bytes', () async {
      late http.Request capturedRequest;
      final client = GoogleTtsClient(
        apiKey: 'api-key-1',
        httpClient: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'audioContent': base64Encode([1, 2, 3]),
            }),
            200,
          );
        }),
      );

      final bytes = await client.synthesize('สวัสดี');
      final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
      final voice = body['voice'] as Map<String, dynamic>;
      final audioConfig = body['audioConfig'] as Map<String, dynamic>;

      expect(bytes, Uint8List.fromList([1, 2, 3]));
      expect(capturedRequest.url.queryParameters['key'], 'api-key-1');
      expect(capturedRequest.method, 'POST');
      expect(voice['languageCode'], 'th-TH');
      expect(voice['name'], 'th-TH-Neural2-C');
      expect(audioConfig['audioEncoding'], 'OGG_OPUS');
      expect(audioConfig['speakingRate'], 0.9);
      expect(audioConfig['pitch'], 2.0);
    });

    test('throws typed exception for non-200 responses', () async {
      final client = GoogleTtsClient(
        apiKey: 'api-key-1',
        httpClient: MockClient((request) async {
          return http.Response('nope', 403);
        }),
      );

      await expectLater(
        client.synthesize('สวัสดี'),
        throwsA(isA<TtsException>()),
      );
    });

    test('throws typed exception for malformed JSON responses', () async {
      final client = GoogleTtsClient(
        apiKey: 'api-key-1',
        httpClient: MockClient((request) async {
          return http.Response('{invalid', 200);
        }),
      );

      await expectLater(
        client.synthesize('สวัสดี'),
        throwsA(isA<TtsException>()),
      );
    });

    test('throws typed exception when audioContent is missing', () async {
      final client = GoogleTtsClient(
        apiKey: 'api-key-1',
        httpClient: MockClient((request) async {
          return http.Response(jsonEncode(<String, Object?>{}), 200);
        }),
      );

      await expectLater(
        client.synthesize('สวัสดี'),
        throwsA(isA<TtsException>()),
      );
    });
  });
}
