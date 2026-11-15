import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/api/overdrive_api_client.dart';

void main() {
  test('normalizeBaseUrl adds scheme and strips slash', () {
    expect(normalizeBaseUrl('192.168.1.10:8080'), 'http://192.168.1.10:8080');
    expect(normalizeBaseUrl('https://car.example.com/'), 'https://car.example.com');
  });
}
