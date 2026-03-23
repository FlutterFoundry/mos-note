// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Memos';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInWithToken => 'Sign in with your Personal Access Token';

  @override
  String get signInWithCredentials => 'Sign in with your credentials';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get credentials => 'Credentials';

  @override
  String get token => 'Token';

  @override
  String get password => 'Password';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get pasteTokenHere => 'Paste your token here';

  @override
  String get enterAccessToken => 'Enter your access token';

  @override
  String get signIn => 'Sign In';

  @override
  String get tokenHelp =>
      'Generate a token in your Memos settings\\nunder Settings > My Account > Access Tokens.';

  @override
  String get invalidToken =>
      'Invalid access token. Make sure it has not expired.';

  @override
  String get connectToMemos => 'Connect to Memos';

  @override
  String get enterInstanceUrl => 'Please enter your Memos instance URL';

  @override
  String get instanceUrl => 'Instance URL';

  @override
  String get instanceUrlHint => 'https://demo.usememos.com';

  @override
  String get continueBtn => 'Continue';

  @override
  String get connectionFailed =>
      'Could not connect to the instance. Check the URL.';

  @override
  String get memosInfo =>
      'Memos is open-source, self-hosted note taking.\\nLearn more at usememos.com';

  @override
  String get searchMemos => 'Search memos...';

  @override
  String get noMemos => 'No memos yet';

  @override
  String get noResults => 'No results found';

  @override
  String get createFirst => 'Tap + to create your first memo';

  @override
  String get failedToLoad => 'Failed to load memos';

  @override
  String get retry => 'Retry';

  @override
  String get all => 'All';

  @override
  String get savedOffline => 'Saved offline';

  @override
  String get offline => 'Offline';

  @override
  String get pendingSync => 'change(s) pending sync';

  @override
  String get showingCached => 'showing cached memos';

  @override
  String get synced => 'Synced';

  @override
  String syncedPending(int count) {
    return 'Synced ($count pending uploaded)';
  }

  @override
  String get newMemo => 'New Memo';

  @override
  String get editMemo => 'Edit Memo';

  @override
  String get writeMemo => 'Write your memo... (type / for formatting)';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String failedToSave(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get private => 'Private';

  @override
  String get protected => 'Protected';

  @override
  String get public => 'Public';

  @override
  String get format => 'Format';

  @override
  String get heading1 => 'Heading 1';

  @override
  String get heading2 => 'Heading 2';

  @override
  String get heading3 => 'Heading 3';

  @override
  String get bold => 'Bold';

  @override
  String get italic => 'Italic';

  @override
  String get inlineCode => 'Inline Code';

  @override
  String get codeBlock => 'Code Block';

  @override
  String get blockquote => 'Blockquote';

  @override
  String get bulletList => 'Bullet List';

  @override
  String get numberedList => 'Numbered List';

  @override
  String get task => 'Task';

  @override
  String get link => 'Link';

  @override
  String get divider => 'Divider';

  @override
  String get tag => 'Tag';

  @override
  String get profile => 'Profile';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get instance => 'Instance';

  @override
  String get account => 'Account';

  @override
  String get username => 'Username';

  @override
  String get description => 'Description';

  @override
  String get settings => 'Settings';

  @override
  String get changeInstance => 'Change Instance';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirm => 'Sign out';

  @override
  String get signOutMessage => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get comments => 'Comments';

  @override
  String get noComments => 'No comments yet';

  @override
  String get addComment => 'Add a comment...';

  @override
  String get shareMemo => 'Share Memo';

  @override
  String get shareContentAndLink => 'Share content and link';

  @override
  String get shareLinkOnly => 'Share link only';

  @override
  String get memoNotFound => 'Memo not found';

  @override
  String get deleteMemo => 'Delete memo';

  @override
  String get deleteMemoConfirm => 'This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';
}
