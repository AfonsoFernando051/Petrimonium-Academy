import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';

void main() {
  test('AppSpacing scale is strictly increasing', () {
    expect(AppSpacing.xs, lessThan(AppSpacing.sm));
    expect(AppSpacing.sm, lessThan(AppSpacing.md));
    expect(AppSpacing.md, lessThan(AppSpacing.lg));
    expect(AppSpacing.lg, lessThan(AppSpacing.xl));
    expect(AppSpacing.xl, lessThan(AppSpacing.xxl));
    expect(AppSpacing.xxl, lessThan(AppSpacing.xxxl));
  });
}
