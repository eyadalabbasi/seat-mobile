import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

abstract final class SeatDateTime {
  static String dateTime(BuildContext context, DateTime value) {
    final local = value.toLocal();
    final locale = Localizations.localeOf(context).languageCode;
    final today = _dateOnly(DateTime.now());
    final day = _dateOnly(local);
    final relative = day == today
        ? (locale == 'ar' ? 'اليوم' : 'Today')
        : day == today.add(const Duration(days: 1))
        ? (locale == 'ar' ? 'غداً' : 'Tomorrow')
        : DateFormat('d MMM', locale).format(local);
    return _latinDigits('$relative · ${DateFormat.jm(locale).format(local)}');
  }

  static String date(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).languageCode;
    return _latinDigits(DateFormat('EEEE، d MMMM', locale).format(value));
  }

  static String time(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).languageCode;
    return _latinDigits(DateFormat.jm(locale).format(value.toLocal()));
  }

  static String relative(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).languageCode;
    final difference = DateTime.now().difference(value.toLocal());
    if (difference.inMinutes < 1) return locale == 'ar' ? 'الآن' : 'Now';
    if (difference.inHours < 1) {
      return locale == 'ar'
          ? 'منذ ${difference.inMinutes} د'
          : '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return locale == 'ar'
          ? 'منذ ${difference.inHours} س'
          : '${difference.inHours}h ago';
    }
    return dateTime(context, value);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String _latinDigits(String value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    var result = value;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(arabic[i], '$i').replaceAll(persian[i], '$i');
    }
    return result;
  }
}
