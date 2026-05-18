class TimeUtils {
  static String getYear(String? pubDate) {
    if (pubDate == null) return '';
    final text = pubDate.trim();
    if (text.isEmpty) return '';
    final dateTime = DateTime.tryParse(text);
    if (dateTime == null) return '';
    return dateTime.year.toString();
  }
}
