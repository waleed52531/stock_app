class ApiConfig {
  ApiConfig._();

  /// Polygon.io API key. Override at runtime with --dart-define=POLYGON_API_KEY.
  static const polygonApiKey = String.fromEnvironment(
    'POLYGON_API_KEY',
    defaultValue: '01kYNfBSwdvAiS_IOtvVli2bMD3aBU2J',
  );

  /// NewsAPI key. Override at runtime with --dart-define=NEWS_API_KEY.
  static const newsApiKey = String.fromEnvironment(
    'NEWS_API_KEY',
    defaultValue: '432ce4b1fc3842fa8bccacdb3470f584',
  );
}
