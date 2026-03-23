import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Memos'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInWithToken.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your Personal Access Token'**
  String get signInWithToken;

  /// No description provided for @signInWithCredentials.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your credentials'**
  String get signInWithCredentials;

  /// No description provided for @personalAccessToken.
  ///
  /// In en, this message translates to:
  /// **'Personal Access Token'**
  String get personalAccessToken;

  /// No description provided for @credentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get credentials;

  /// No description provided for @token.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get token;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @pasteTokenHere.
  ///
  /// In en, this message translates to:
  /// **'Paste your token here'**
  String get pasteTokenHere;

  /// No description provided for @enterAccessToken.
  ///
  /// In en, this message translates to:
  /// **'Enter your access token'**
  String get enterAccessToken;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @tokenHelp.
  ///
  /// In en, this message translates to:
  /// **'Generate a token in your Memos settings\\nunder Settings > My Account > Access Tokens.'**
  String get tokenHelp;

  /// No description provided for @invalidToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid access token. Make sure it has not expired.'**
  String get invalidToken;

  /// No description provided for @connectToMemos.
  ///
  /// In en, this message translates to:
  /// **'Connect to Memos'**
  String get connectToMemos;

  /// No description provided for @enterInstanceUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Memos instance URL'**
  String get enterInstanceUrl;

  /// No description provided for @instanceUrl.
  ///
  /// In en, this message translates to:
  /// **'Instance URL'**
  String get instanceUrl;

  /// No description provided for @instanceUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://demo.usememos.com'**
  String get instanceUrlHint;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the instance. Check the URL.'**
  String get connectionFailed;

  /// No description provided for @memosInfo.
  ///
  /// In en, this message translates to:
  /// **'Memos is open-source, self-hosted note taking.\\nLearn more at usememos.com'**
  String get memosInfo;

  /// No description provided for @searchMemos.
  ///
  /// In en, this message translates to:
  /// **'Search memos...'**
  String get searchMemos;

  /// No description provided for @noMemos.
  ///
  /// In en, this message translates to:
  /// **'No memos yet'**
  String get noMemos;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @createFirst.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first memo'**
  String get createFirst;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load memos'**
  String get failedToLoad;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @savedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved offline'**
  String get savedOffline;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'change(s) pending sync'**
  String get pendingSync;

  /// No description provided for @showingCached.
  ///
  /// In en, this message translates to:
  /// **'showing cached memos'**
  String get showingCached;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @syncedPending.
  ///
  /// In en, this message translates to:
  /// **'Synced ({count} pending uploaded)'**
  String syncedPending(int count);

  /// No description provided for @newMemo.
  ///
  /// In en, this message translates to:
  /// **'New Memo'**
  String get newMemo;

  /// No description provided for @editMemo.
  ///
  /// In en, this message translates to:
  /// **'Edit Memo'**
  String get editMemo;

  /// No description provided for @writeMemo.
  ///
  /// In en, this message translates to:
  /// **'Write your memo... (type / for formatting)'**
  String get writeMemo;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String failedToSave(String error);

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @protected.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get protected;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @heading1.
  ///
  /// In en, this message translates to:
  /// **'Heading 1'**
  String get heading1;

  /// No description provided for @heading2.
  ///
  /// In en, this message translates to:
  /// **'Heading 2'**
  String get heading2;

  /// No description provided for @heading3.
  ///
  /// In en, this message translates to:
  /// **'Heading 3'**
  String get heading3;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @inlineCode.
  ///
  /// In en, this message translates to:
  /// **'Inline Code'**
  String get inlineCode;

  /// No description provided for @codeBlock.
  ///
  /// In en, this message translates to:
  /// **'Code Block'**
  String get codeBlock;

  /// No description provided for @blockquote.
  ///
  /// In en, this message translates to:
  /// **'Blockquote'**
  String get blockquote;

  /// No description provided for @bulletList.
  ///
  /// In en, this message translates to:
  /// **'Bullet List'**
  String get bulletList;

  /// No description provided for @numberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered List'**
  String get numberedList;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @divider.
  ///
  /// In en, this message translates to:
  /// **'Divider'**
  String get divider;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @instance.
  ///
  /// In en, this message translates to:
  /// **'Instance'**
  String get instance;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @changeInstance.
  ///
  /// In en, this message translates to:
  /// **'Change Instance'**
  String get changeInstance;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutConfirm;

  /// No description provided for @signOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noComments;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addComment;

  /// No description provided for @shareMemo.
  ///
  /// In en, this message translates to:
  /// **'Share Memo'**
  String get shareMemo;

  /// No description provided for @shareContentAndLink.
  ///
  /// In en, this message translates to:
  /// **'Share content and link'**
  String get shareContentAndLink;

  /// No description provided for @shareLinkOnly.
  ///
  /// In en, this message translates to:
  /// **'Share link only'**
  String get shareLinkOnly;

  /// No description provided for @memoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Memo not found'**
  String get memoNotFound;

  /// No description provided for @deleteMemo.
  ///
  /// In en, this message translates to:
  /// **'Delete memo'**
  String get deleteMemo;

  /// No description provided for @deleteMemoConfirm.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteMemoConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
