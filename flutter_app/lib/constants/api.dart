class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // Citizen endpoints
  static const String citizenRegister = '$baseUrl/citizen/register/';
  static String citizenProfile(String uuid) => '$baseUrl/citizen/$uuid/profile/';
  static String citizenHistory(String uuid) => '$baseUrl/citizen/$uuid/history/';

  // Disposal endpoints
  static const String disposalInitiate = '$baseUrl/disposal/initiate/';
  static const String disposalVerify = '$baseUrl/disposal/verify/';
  static const String homeGuide = '$baseUrl/disposal/home-guide/';

  // Pharmacy endpoints
  static const String pharmacies = '$baseUrl/pharmacies/';
  static const String pharmaciesNearby = '$baseUrl/pharmacies/nearby/';

  // Rewards endpoints
  static const String leaderboard = '$baseUrl/rewards/leaderboard/';
  static String citizenBadges(String uuid) => '$baseUrl/rewards/badges/$uuid/';

  // Analytics endpoints
  static const String analyticsStats = '$baseUrl/analytics/stats/';

  // Chatbot endpoints
  static const String chatbot = '$baseUrl/chatbot/chat/';
}
