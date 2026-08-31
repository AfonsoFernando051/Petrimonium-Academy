import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_motion.dart';

void main() {
  test('AppMotion.pageTransition is 350ms', () {
    expect(AppMotion.pageTransition, const Duration(milliseconds: 350));
  });
}
