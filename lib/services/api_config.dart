import 'package:flutter_dotenv/flutter_dotenv.dart';

String get newsApiKey => dotenv.env['NEWS_API_KEY']?.trim() ?? '';
String get currencyApiKey => dotenv.env['CURRENCY_API_KEY']?.trim() ?? '';
