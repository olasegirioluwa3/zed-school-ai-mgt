// API Configuration for ZED AI
class ApiConfig {
  // Temporary test school ID - will be replaced by authenticated user's selected school
  static const String testSchoolId = 'YOUR_TEST_SCHOOL_ID';
  
  // ZED AI API Base URL
  static const String zedAiBaseUrl = 'https://zed.api.zionai.com.ng';
  
  // API Endpoints
  static const String chatEndpoint = '/api/v2/user/zedai/chat';
  static const String conversationsEndpoint = '/api/v2/user/zedai/conversations';
  static const String schoolsEndpoint = '/api/v2/user/schoolowner';
  static const String loginEndpoint = '/api/v2/auth/login';
  
  // Request timeout in seconds
  static const int requestTimeout = 30;
  
  // Authentication token - will be set after login is implemented
  static String authToken = '';
  
  // Set authentication token (to be called after login)
  static void setAuthToken(String token) {
    authToken = token;
  }
}
