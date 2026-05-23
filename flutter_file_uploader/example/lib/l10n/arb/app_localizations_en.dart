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
  String get addFilePlaceholder => 'Tap to add a file';

  @override
  String get defaultTitle => 'Default';

  @override
  String get defaultBannerTitle => 'FileUploader — Basic Usage';

  @override
  String get defaultBannerDescription =>
      'The simplest way to use FileUploader. Files are added by tapping the button and uploaded asynchronously in the background. The built-in ProvidedFileCard displays a real-time upload progress bar for each file.';

  @override
  String get restorableTitle => 'Restorable chunked';

  @override
  String get restorableBannerTitle =>
      'FileUploader — Restorable Chunked Upload';

  @override
  String get restorableBannerDescription =>
      'Demonstrates chunked upload with resume support. The file is split into smaller chunks and sent one at a time. If the upload is interrupted (e.g. network loss or app crash), it automatically resumes from the last successfully uploaded chunk — no need to restart from scratch.';

  @override
  String get selfRefTitle => 'Self-managed card';

  @override
  String get selfRefBannerTitle =>
      'FileUploader — Custom Card with Self-Managed State';

  @override
  String get selfRefBannerDescription =>
      'Shows how to build a fully custom file card that manages its own upload state, without relying on ProvidedFileCard. The card receives a FileUploaderRef, which exposes the upload controller. It manually triggers the upload and reacts to its outcome (success or error) by updating its own local state.';

  @override
  String get fileUploadedText => 'File uploaded successfully';

  @override
  String get errorUploadingText => 'Upload failed — please try again';

  @override
  String get uploadButtonText => 'Upload';

  @override
  String get transformersTitle => 'Transformers';

  @override
  String get transformersBannerTitle =>
      'FileUploader — File Transformers Pipeline';

  @override
  String get transformersBannerDescription =>
      'Shows how to apply a sequential pipeline of transformers to each file before it is uploaded. Transformers run in order: each one receives the output of the previous. In this example, two no-op transformers are used as placeholders — replace them with real logic such as compression, format conversion or metadata injection.';

  @override
  String get completeTitle => 'Complete';

  @override
  String get completeBannerTitle => 'FileUploader — Full-Featured Example';

  @override
  String get completeBannerDescription =>
      'A comprehensive example combining multiple features: files are selected from the file system or dropped via drag-and-drop. Each file goes through a transformer that resizes the image before uploading. The custom card shows both the transformation progress and the upload progress in real time. This example is the best starting point for production-like integrations.';

  @override
  String get languageTitle => 'Language / Lingua';

  @override
  String get languageSubtitle => 'Select application language';

  @override
  String get englishOption => 'English 🇺🇸';

  @override
  String get italianOption => 'Italiano 🇮🇹';
}
