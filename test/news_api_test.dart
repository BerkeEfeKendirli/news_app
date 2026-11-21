import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:news_app/services/news_api.dart';

void main() {
  test('Search uses HTTPS and preserves special characters', () async {
    final client = MockClient((request) async {
      expect(request.url.scheme, 'https');
      expect(request.url.queryParameters['q'], 'science & technology + space');
      expect(request.url.queryParameters.containsKey('apiKey'), isFalse);
      expect(request.headers['X-Api-Key'], 'test-key');
      return http.Response('{"status":"ok","articles":[]}', 200);
    });
    addTearDown(client.close);
    final data = await NewsApi(
      client: client,
      apiKey: 'test-key',
    ).get('everything', {'q': 'science & technology + space'});
    expect(data['articles'], isEmpty);
  });

  test('Missing credentials do not send a request', () async {
    final client = MockClient((_) async => fail('Unexpected request'));
    addTearDown(client.close);
    await expectLater(
      NewsApi(client: client, apiKey: '').get('top-headlines', {}),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'HTTP failures are reported without exposing the response body',
    () async {
      final client = MockClient(
        (_) async => http.Response('sensitive body', 401),
      );
      addTearDown(client.close);
      await expectLater(
        NewsApi(client: client, apiKey: 'test-key').get('top-headlines', {}),
        throwsA(
          predicate(
            (error) =>
                error.toString().contains('401') &&
                !error.toString().contains('sensitive body'),
          ),
        ),
      );
    },
  );
}
