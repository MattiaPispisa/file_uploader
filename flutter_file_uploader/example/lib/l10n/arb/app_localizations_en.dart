// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get filenamePlaceholder => 'filename';

  @override
  String get addFilePlaceholder => 'add a file';

  @override
  String get defaultTitle => 'Default';

  @override
  String get defaultBannerTitle => 'FileUploader + Default Usage';

  @override
  String get defaultBannerDescription =>
      'A basic FileUploader where files are added and uploaded asynchronously. It uses the default ProvidedFileCard to show the upload progress bar.';

  @override
  String get restorableTitle => 'Default restorable chunked';

  @override
  String get restorableBannerTitle =>
      'FileUploader + Restorable Chunked Upload';

  @override
  String get restorableBannerDescription =>
      'An example of chunked upload where uploading can be resumed from where it left off (restorable). If the upload fails or is interrupted, the uploader will resume sending only the missing chunks.';

  @override
  String get selfRefTitle => 'Self ref management';

  @override
  String get selfRefBannerTitle =>
      'FileUploader + Custom Card & Self State Management';

  @override
  String get selfRefBannerDescription =>
      'This example shows how to create a custom card to manage the upload state independently (self-managed) using the controller provided via FileUploaderRef.';

  @override
  String get fileUploadedText => 'file uploaded';

  @override
  String get errorUploadingText => 'error uploading';

  @override
  String get uploadButtonText => 'upload';

  @override
  String get transformersTitle => 'Transformers';

  @override
  String get transformersBannerTitle => 'FileUploader + Automated Transformers';

  @override
  String get transformersBannerDescription =>
      'Shows how to apply a cascade of transformers (in this case two dummy no-op transformers) on added files before they are actually uploaded to the backend.';

  @override
  String get completeTitle => 'Complete';

  @override
  String get completeBannerTitle => 'FileUploader + Complete';

  @override
  String get completeBannerDescription =>
      'A FileUploader where files are added from the file system, then a transformation resizing the image is applied to each file. After the transformation is complete, the file is uploaded to the backend. The UI shows both upload and transformation progress. Also a drag and drop zone is present to add files.';

  @override
  String get languageTitle => 'Language / Lingua';

  @override
  String get languageSubtitle => 'Select application language';

  @override
  String get englishOption => 'English 🇺🇸';

  @override
  String get italianOption => 'Italiano 🇮🇹';
}
