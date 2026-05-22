import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
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
    Locale('it')
  ];

  /// No description provided for @filenamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'filename'**
  String get filenamePlaceholder;

  /// No description provided for @addFilePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'add a file'**
  String get addFilePlaceholder;

  /// No description provided for @defaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultTitle;

  /// No description provided for @defaultBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'FileUploader + Default Usage'**
  String get defaultBannerTitle;

  /// No description provided for @defaultBannerDescription.
  ///
  /// In en, this message translates to:
  /// **'A basic FileUploader where files are added and uploaded asynchronously. It uses the default ProvidedFileCard to show the upload progress bar.'**
  String get defaultBannerDescription;

  /// No description provided for @restorableTitle.
  ///
  /// In en, this message translates to:
  /// **'Default restorable chunked'**
  String get restorableTitle;

  /// No description provided for @restorableBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'FileUploader + Restorable Chunked Upload'**
  String get restorableBannerTitle;

  /// No description provided for @restorableBannerDescription.
  ///
  /// In en, this message translates to:
  /// **'An example of chunked upload where uploading can be resumed from where it left off (restorable). If the upload fails or is interrupted, the uploader will resume sending only the missing chunks.'**
  String get restorableBannerDescription;

  /// No description provided for @selfRefTitle.
  ///
  /// In en, this message translates to:
  /// **'Self ref management'**
  String get selfRefTitle;

  /// No description provided for @selfRefBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'FileUploader + Custom Card & Self State Management'**
  String get selfRefBannerTitle;

  /// No description provided for @selfRefBannerDescription.
  ///
  /// In en, this message translates to:
  /// **'This example shows how to create a custom card to manage the upload state independently (self-managed) using the controller provided via FileUploaderRef.'**
  String get selfRefBannerDescription;

  /// No description provided for @fileUploadedText.
  ///
  /// In en, this message translates to:
  /// **'file uploaded'**
  String get fileUploadedText;

  /// No description provided for @errorUploadingText.
  ///
  /// In en, this message translates to:
  /// **'error uploading'**
  String get errorUploadingText;

  /// No description provided for @uploadButtonText.
  ///
  /// In en, this message translates to:
  /// **'upload'**
  String get uploadButtonText;

  /// No description provided for @transformersTitle.
  ///
  /// In en, this message translates to:
  /// **'Transformers'**
  String get transformersTitle;

  /// No description provided for @transformersBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'FileUploader + Automated Transformers'**
  String get transformersBannerTitle;

  /// No description provided for @transformersBannerDescription.
  ///
  /// In en, this message translates to:
  /// **'Shows how to apply a cascade of transformers (in this case two dummy no-op transformers) on added files before they are actually uploaded to the backend.'**
  String get transformersBannerDescription;

  /// No description provided for @completeTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeTitle;

  /// No description provided for @completeBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'FileUploader + Complete'**
  String get completeBannerTitle;

  /// No description provided for @completeBannerDescription.
  ///
  /// In en, this message translates to:
  /// **'A FileUploader where files are added from the file system, then a transformation resizing the image is applied to each file. After the transformation is complete, the file is uploaded to the backend. The UI shows both upload and transformation progress. Also a drag and drop zone is present to add files.'**
  String get completeBannerDescription;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language / Lingua'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select application language'**
  String get languageSubtitle;

  /// No description provided for @englishOption.
  ///
  /// In en, this message translates to:
  /// **'English 🇺🇸'**
  String get englishOption;

  /// No description provided for @italianOption.
  ///
  /// In en, this message translates to:
  /// **'Italiano 🇮🇹'**
  String get italianOption;
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
