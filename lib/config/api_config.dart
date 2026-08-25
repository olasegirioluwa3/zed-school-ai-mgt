// API Configuration for ZED AI
class ApiConfig {
  // ZED AI API Base URL
  static const String zedAiBaseUrl = 'https://zed.api.zionai.com.ng';
  
  // API Endpoints
  static const String chatEndpoint = '/api/v2/user/zedai/chat';
  static const String conversationsEndpoint = '/api/v2/user/zedai/conversations';
  static const String schoolsEndpoint = '/api/v2/user/school/i-have-access';
  static const String loginEndpoint = '/api/auth/login';
  
  // Request timeout in seconds
  static const int requestTimeout = 30;
  
  // Authentication token - will be set after login is implemented
  static String authToken = '';
  static dynamic currentUser;
  
  // Set authentication token (to be called after login)
  static void setAuthToken(String token) {
    authToken = token;
  }

  // Set current logged-in user
  static void setCurrentUser(dynamic user) {
    currentUser = user;
  }
}
