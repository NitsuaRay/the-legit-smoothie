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

  /// Formats DateTime or ISO string to readable date (e.g., Oct 24, 2026 • 02:30 PM)
  static String formatDate(dynamic dateInput) {
    if (dateInput == null) return 'N/A';

    DateTime? date;
    if (dateInput is DateTime) {
      date = dateInput;
    } else if (dateInput is String) {
      date = DateTime.tryParse(dateInput);
    }

    if (date == null) return 'N/A';

    // Converts UTC timestamp from Supabase to local device time
    final localDate = date.toLocal();

    return DateFormat('MMM dd, yyyy • hh:mm a').format(localDate);
  }
}