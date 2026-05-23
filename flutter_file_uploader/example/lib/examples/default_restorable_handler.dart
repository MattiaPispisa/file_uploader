import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader_example/common/banner.dart';
import 'package:flutter_file_uploader_example/common/view_layout.dart';
import 'package:flutter_file_uploader_example/handlers/handlers.dart';
import 'package:flutter_file_uploader_example/l10n/l10n.dart';

/// [FileUploader] and [ProvidedFileCard]
/// with [InMemoryRestorableChunkedFileUploadHandler].
class DefaultRestorableChunkedFilesUpload extends StatelessWidget {
  const DefaultRestorableChunkedFilesUpload({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewLayout(
      title: context.t().restorableTitle.toUpperCase(),
      childrenBuilder: (settings) {
        return [
          ExampleBanner(
            title: context.t().restorableBannerTitle,
            description: context.t().restorableBannerDescription,
          ),
          Center(
            child: FileUploader(
              limit: settings.limit,
              hideOnLimit: settings.hideOnLimit,
              color: settings.color,
              builder: (context, ref) {
                return ProvidedFileCard(
                  ref: ref,
                  content: Text(context.t().filenamePlaceholder),
                );
              },
              onPressedAddFiles: () async {
                await Future.delayed(const Duration(seconds: 1));
                return [utils.createFile()];
              },
              onFileAdded: (file) async {
                await Future.delayed(const Duration(milliseconds: 500));
                return InMemoryRestorableChunkedFileUploadHandler(
                  file: file,
                );
              },
              onFileUploaded: (file) {
                utils.logger.info("file uploaded ${file.id}");
              },
              onFileRemoved: (file) {
                utils.logger.info("file removed ${file.id}");
              },
              placeholder: Text(context.t().addFilePlaceholder),
            ),
          ),
        ];
      },
    );
  }
}
