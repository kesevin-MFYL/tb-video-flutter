import 'dart:math';

class StringUtils {

  static String generateSessionId() {
    final random = Random();
    final int part1 = 100 + random.nextInt(900); // 3 digits: 100-999
    final int part2 = 1000000 + random.nextInt(9000000); // 7 digits: 1000000-9999999
    final int part3 = 1000000 + random.nextInt(9000000); // 7 digits: 1000000-9999999
    return '$part1-$part2-$part3';
  }

  static String formatVideoDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours.remainder(60));
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
