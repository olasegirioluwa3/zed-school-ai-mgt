class ZedApiException implements Exception {
  final String message;
  final String? errorDetails;
  final int? statusCode;

  ZedApiException(
    this.message, {
    this.errorDetails,
    this.statusCode,
  });

  @override
  String toString() {
    return 'ZedApiException: $message${errorDetails != null ? ' ($errorDetails)' : ''}';
  }
}
