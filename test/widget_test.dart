import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:news_app/screens/home_news.dart';
import 'package:news_app/screens/currency_page.dart';

void main() {
  setUp(
    () => dotenv.loadFromString(envString: 'NEWS_API_KEY=\nCURRENCY_API_KEY='),
  );

  testWidgets('Missing news key shows a message instead of loading forever', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomePage())),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('News API key is missing'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Missing currency key shows a message', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CurrencyPage()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Currency API key is missing'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
