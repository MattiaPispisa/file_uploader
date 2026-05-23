// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get filenamePlaceholder => 'nomefile';

  @override
  String get addFilePlaceholder => 'Tocca per aggiungere un file';

  @override
  String get defaultTitle => 'Default';

  @override
  String get defaultBannerTitle => 'FileUploader — Utilizzo Base';

  @override
  String get defaultBannerDescription =>
      'Il modo più semplice per usare FileUploader. I file vengono aggiunti toccando il pulsante e caricati in modo asincrono in background. La ProvidedFileCard integrata mostra una barra di avanzamento in tempo reale per ogni file in fase di caricamento.';

  @override
  String get restorableTitle => 'Chunked ripristinabile';

  @override
  String get restorableBannerTitle =>
      'FileUploader — Caricamento a Blocchi Ripristinabile';

  @override
  String get restorableBannerDescription =>
      'Dimostra il caricamento a blocchi (chunked) con supporto alla ripresa. Il file viene suddiviso in blocchi più piccoli e inviato un blocco alla volta. Se il caricamento viene interrotto (ad es. per perdita di rete o chiusura dell\'app), riprende automaticamente dall\'ultimo blocco caricato con successo — senza ricominciare da capo.';

  @override
  String get selfRefTitle => 'Card autonoma';

  @override
  String get selfRefBannerTitle =>
      'FileUploader — Card Personalizzata con Stato Autonomo';

  @override
  String get selfRefBannerDescription =>
      'Mostra come costruire una card completamente personalizzata che gestisce autonomamente il proprio stato di caricamento, senza dipendere da ProvidedFileCard. La card riceve un FileUploaderRef, che espone il controller di upload. Avvia il caricamento manualmente e reagisce al risultato (successo o errore) aggiornando il proprio stato locale.';

  @override
  String get fileUploadedText => 'File caricato con successo';

  @override
  String get errorUploadingText => 'Caricamento fallito — riprova';

  @override
  String get uploadButtonText => 'Carica';

  @override
  String get transformersTitle => 'Transformer';

  @override
  String get transformersBannerTitle =>
      'FileUploader — Pipeline di Transformer';

  @override
  String get transformersBannerDescription =>
      'Mostra come applicare una pipeline sequenziale di transformer a ogni file prima che venga caricato. I transformer vengono eseguiti in ordine: ciascuno riceve l\'output del precedente. In questo esempio vengono usati due transformer no-op come segnaposto — sostituiscili con logica reale come compressione, conversione di formato o aggiunta di metadati.';

  @override
  String get completeTitle => 'Completo';

  @override
  String get completeBannerTitle => 'FileUploader — Esempio Completo';

  @override
  String get completeBannerDescription =>
      'Un esempio esaustivo che combina più funzionalità: i file vengono selezionati dal file system oppure trascinati tramite drag-and-drop. Ogni file passa attraverso un transformer che ridimensiona l\'immagine prima del caricamento. La card personalizzata mostra in tempo reale sia il progresso della trasformazione che quello del caricamento. Questo esempio è il punto di partenza ideale per integrazioni simili alla produzione.';

  @override
  String get languageTitle => 'Lingua / Language';

  @override
  String get languageSubtitle => 'Seleziona la lingua dell\'applicazione';

  @override
  String get englishOption => 'English 🇺🇸';

  @override
  String get italianOption => 'Italiano 🇮🇹';
}
