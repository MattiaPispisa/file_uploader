// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get imagePickerTitle => 'Image picker';

  @override
  String get imagePickerBannerTitle =>
      'FileUploader + Selettore Immagini + Trasformatore Immagini';

  @override
  String get imagePickerBannerDescription =>
      'Un FileUploader in cui i file vengono aggiunti prendendoli dal file system dopodiché per ogni file viene applicata una trasformazione che in questo caso ridimensiona l\'immagine. Al termine della trasformazione il file verrà caricato nel backend. L\'interfaccia utente mostra sia il progresso di upload che il progresso di trasformazione';

  @override
  String get filenamePlaceholder => 'nomefile';

  @override
  String get addFilePlaceholder => 'aggiungi un file';

  @override
  String get defaultTitle => 'Default';

  @override
  String get defaultBannerTitle => 'FileUploader + Uso Predefinito';

  @override
  String get defaultBannerDescription =>
      'Un FileUploader base in cui i file vengono inseriti e caricati in modo asincrono. Utilizza il ProvidedFileCard di default per mostrare la barra di progresso dell\'upload.';

  @override
  String get restorableTitle => 'Default restorable chunked';

  @override
  String get restorableBannerTitle =>
      'FileUploader + Caricamento a Pezzi Ripristinabile';

  @override
  String get restorableBannerDescription =>
      'Un esempio di caricamento a pezzi (chunked) in cui è possibile riprendere il caricamento da dove si era interrotto (restorable). Se il caricamento fallisce o viene interrotto, l\'uploader riprenderà l\'invio solo dei chunk mancanti.';

  @override
  String get selfRefTitle => 'Self ref management';

  @override
  String get selfRefBannerTitle =>
      'FileUploader + Card Personalizzata & Gestione Autonoma dello Stato';

  @override
  String get selfRefBannerDescription =>
      'In questo esempio viene mostrato come creare una card personalizzata per gestire lo stato di caricamento in modo indipendente (self-managed) utilizzando il controller fornito tramite FileUploaderRef.';

  @override
  String get fileUploadedText => 'file caricato';

  @override
  String get errorUploadingText => 'errore durante il caricamento';

  @override
  String get uploadButtonText => 'carica';

  @override
  String get transformersTitle => 'Transformers';

  @override
  String get transformersBannerTitle =>
      'FileUploader + Trasformatori Automatici';

  @override
  String get transformersBannerDescription =>
      'Mostra come applicare una serie di trasformatori in cascata (in questo caso due trasformatori fittizi no-op) sui file aggiunti prima che vengano effettivamente caricati nel backend.';

  @override
  String get languageTitle => 'Lingua / Language';

  @override
  String get languageSubtitle => 'Seleziona la lingua dell\'applicazione';

  @override
  String get englishOption => 'English 🇺🇸';

  @override
  String get italianOption => 'Italiano 🇮🇹';
}
