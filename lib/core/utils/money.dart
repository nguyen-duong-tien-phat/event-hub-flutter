import 'package:intl/intl.dart';

final _usd = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

/// "$25.00"
String formatMoney(num amount) => _usd.format(amount);

/// Like [formatMoney], but "Free" for zero.
String formatPrice(num amount) => amount == 0 ? 'Free' : formatMoney(amount);
