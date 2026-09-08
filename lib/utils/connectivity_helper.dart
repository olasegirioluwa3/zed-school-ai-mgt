class ConnectivityHelper {
  static Future<void> throwIfNoInternet() async {
    // Stub implementation - always passes for now
    // In production, this would check network connectivity
    // and throw an exception if offline
    return;
  }

  static Future<bool> hasInternetConnection() async {
    // Stub implementation - always returns true for now
    return true;
  }
}
