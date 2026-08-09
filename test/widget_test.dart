import 'package:flutter_test/flutter_test.dart';

import 'package:kinquest/main.dart';

void main() {
  testWidgets('shows the KinQuest welcome screen', (tester) async {
    await tester.pumpWidget(const KinQuestApp());

    expect(find.text('KinQuest'), findsOneWidget);
    expect(
      find.text('Play Together. Learn Together. Grow Together.'),
      findsOneWidget,
    );
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
