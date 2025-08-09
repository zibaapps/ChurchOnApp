import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:church_on_app/app/app.dart';

void main() {
  testWidgets('App renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChurchOnApp()));
    await tester.pumpAndSettle();
    expect(find.byType(ChurchOnApp), findsOneWidget);
  });
}
