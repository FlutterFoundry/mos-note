class AppConstants {
  static const appName = 'Memos';
  static const memosInstanceKey = 'memos_instance_url';
  static const authTokenKey = 'auth_token';
  static const accessTokenKey = 'access_token'; // personal access token (PAT)
  static const accessTokenExpiryKey = 'access_token_expiry';
  static const userIdKey = 'user_id';
  static const usernameKey = 'username';
  static const userNicknameKey = 'user_nickname';
  static const userEmailKey = 'user_email';
  static const userRoleKey = 'user_role';
  static const themeKey = 'theme_mode';
  static const localeKey = 'app_locale';

  // API
  static const apiVersion = '/api/v1';
  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const pageSize = 20;

  // Deep link
  static const deepLinkScheme = 'memos';
  static const deepLinkHost = 'app';

  // DB
  static const dbName = 'memos_local.db';
  static const dbVersion = 3;
}
