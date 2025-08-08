import 'package:flutter_test/flutter_test.dart';
import 'package:church_on_app/app/app.dart';

void main() {
  testWidgets('App renders', (tester) async {
    await tester.pumpWidget(const ChurchOnApp());
    expect(find.textContaining('Church'), findsWidgets);
  });
}
