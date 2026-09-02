class QRService {
  static String buildURL(String url) {
    return url.trim();
  }

  static String buildText(String text) {
    return text.trim();
  }

  static String buildEmail({
    required String email,
    String subject = '',
    String body = '',
  }) {
    final encodedSubject = Uri.encodeComponent(subject);
    final encodedBody = Uri.encodeComponent(body);

    return 'mailto:${email.trim()}'
        '?subject=$encodedSubject'
        '&body=$encodedBody';
  }

  static String buildPhone(String phone) {
    return 'tel:${phone.trim()}';
  }

  static String buildWifi({
    required String ssid,
    required String password,
    String security = 'WPA',
    bool hidden = false,
  }) {
    return 'WIFI:'
        'T:$security;'
        'S:${ssid.trim()};'
        'P:${password.trim()};'
        'H:${hidden ? 'true' : 'false'};;';
  }

  static bool isValidUrl(String value) {
    final uri = Uri.tryParse(value.trim());

    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static bool isValidEmail(String value) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(value.trim());
  }
}