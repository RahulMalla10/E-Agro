import 'package:flutter_test/flutter_test.dart';
import 'package:krishi_smart/core/errors/app_exception.dart';

void main() {
  test('ConsentRequiredException has default message', () {
    const e = ConsentRequiredException();
    expect(e.message, contains('consent'));
  });
}
