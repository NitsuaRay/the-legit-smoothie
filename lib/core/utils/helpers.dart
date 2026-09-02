import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class AppHelpers {
  /// Formats double numbers to currency string (e.g., 120.00 -> ₱120.00)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '${AppConstants.currencySymbol} ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}