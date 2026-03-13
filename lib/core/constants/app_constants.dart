class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Namaste Nirvana';
  static const String appTagline = 'Massage & Wellness Sanctuary';
  static const String appVersion = '1.0.0';
  static const int appYear = 2026;

  // Contact Info
  static const String contactEmail = 'namastenirvanacontact@gmail.com';
  static const String contactPhone = '(555) 123-4567';
  static const String address = '123 Serenity Lane, Peaceful City, PC 12345';

  // Business Hours
  static const Map<String, String> businessHours = {
    'Monday - Friday': '9:00 AM - 9:00 PM',
    'Saturday': '10:00 AM - 7:00 PM',
    'Sunday': '10:00 AM - 6:00 PM',
  };

  // Social Links
  static const String instagramUrl = 'https://instagram.com/namastenirvana';
  static const String facebookUrl = 'https://facebook.com/namastenirvana';
  static const String twitterUrl = 'https://twitter.com/namastenirvana';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 100.0;
}
